require_relative 'lib/chain'
require_relative 'lib/polygon'
require_relative 'lib/distance'

desc 'Process downloaded information into streets'
task :process, [:geoJSON] => :source do |t, args|
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
    nodes: []
  }}

  streets = ways.reduce(init) do |col, n|
    name = n[:tags][:name]
    raise "empty" if n[:nodes].empty?
    col[name][:name] = name
    col[name][:nodes] << n[:nodes]
    col
  end

  # streets = {a: streets['Willoughby Avenue']}
  streets.map do |name, street|
    # puts street[:nodes].map(&:inspect).join("\n")
    # puts '------'
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
      street[:geo] << line if line.count > 1
    end

    # puts '------'
    # puts street[:geo].first.inspect
    # exit
    street
  end

  streets.reject! { |k, s|
    s[:geo].empty? || s[:geo].map(&method(:line_distance)).reduce(&:+) < 50
  }

  if args[:geoJSON]
    puts JSON.pretty_generate({
      type: 'FeatureCollection',
      features: streets.map {|name, data|
        {
          type: 'Feature',
          properties: {
            name: name,
            stroke: "#d42155",
            'stroke-width' => 5,
            'stroke-opacity' => 0.5,
          },
          geometry: {
            type: 'MultiLineString',
            coordinates: data[:geo]
          }
        }
      }
    })
    exit
  end

end