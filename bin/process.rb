require_relative 'lib/chain'
require_relative 'lib/polygon'
require_relative 'lib/distance'

def to_geoJSON features, style={}
  {
    type: 'FeatureCollection',
    features: features.map do |feature|
      {
        type: 'Feature',
        geometry: {
          type: 'MultiLineString',
          coordinates: feature.delete(:geo)
        },
        properties: feature.merge(style)
      }
    end
  }
end


desc 'Process downloaded information into streets'
task :process, [:print] => :source do |t, args|
  require 'json'
  ALLOWED = %w{primary residential secondary service}

  polygon = Polygon.new $polygon.map(&:reverse)

  o = JSON.parse(File.read(CACHE), symbolize_names: true)[:elements]

  Nodes = o.select {|n|
    n[:type] == 'node'
  }.map {|n| [
    n[:id],
    {
      coords: [n[:lon],n[:lat]],
      ways: []
    }
  ]}.to_h

  ways = o
    .select {|n|
      n[:type] == 'way' &&
      !n[:tags][:name].nil? &&
      ALLOWED.include?(n[:tags][:highway]) &&
      n[:nodes].any? { |i| Nodes.has_key?(i) }
    }

  init = Hash.new { |h,k| h[k] = {
    name: '',
    geo: [],
    crosses: [],
    length: 0.0,
    nodes: []
  }}

  streets = ways.reduce(init) do |col, n|
    name = n[:tags][:name]
    raise "empty" if n[:nodes].empty?
    col[name][:name] = name
    col[name][:nodes] << n[:nodes]
    col
  end

  coords = Hash.new {|h,k| h[k] = []}

  streets = streets.map do |name, street|
    while !street[:nodes].empty?
      line = street[:nodes].shift
      line = line
        .concat(chain(street[:nodes], line, :head))
        .unshift(*chain(street[:nodes], line, :tail))
        .map { |n| Nodes[n][:coords] }
        .select { |coord|
          polygon.contains_point?(*coord)
        }
        .uniq
        .sort
      if line.count > 1
        street[:geo] << line
        street[:length] += line_distance(line)
        line.each {|p| coords[p] << name }
      end
    end
    street
  end
  .reject! do |street|
    if street[:geo].empty? || street[:length] < 40
      street[:geo].flatten.each_slice(2) {|p|
        coords[p].delete(street[:name])
      }
      true
    end
  end
  .map do |street|
    points = street[:geo].flatten
    street[:length] = street[:length]
    street[:crosses] = points
      .each_slice(2)
      .reduce([]) {|col, p|
        col.concat(coords[p])
      }
      .uniq
      .sort

    street[:crosses].delete(street[:name])
    street.delete(:nodes)
    street
  end.sort do |a, b|
    a[:name] <=> b[:name]
  end.each_with_index.map do |street, index|
    street[:id] = index + 1
    street
  end

  if args[:print]
    puts JSON.pretty_generate(to_geoJSON(streets, {
      stroke: "#d42155",
      'stroke-width' => 5,
      'stroke-opacity' => 0.5,
    }))
    exit
  end

  File.open("#{ENV['cwd']}/tmp/streets.geojson", 'w') do |f|
    f << JSON.pretty_generate(to_geoJSON streets)
  end

end