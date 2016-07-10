desc 'Download mapbox maps'
task :maps, :force do |t, args|
  require 'cgi'
  require 'open-uri'
  require 'json'

  url = 'https://api.mapbox.com/v4/mapbox.streets/geojson(%s)/auto/500x500.png?access_token='+ENV['MAPBOX']

  data = JSON.parse(File.read('./tmp/streets.geojson'), symbolize_names: true)

  data[:features].each do |f|
    id = f[:properties][:id]
    file = "./tmp/maps/#{id}.png"

    if args[:force] != 'force'
      next if File.exists?(file)
    end

    name = f[:properties][:name]
    f[:properties] = {
      stroke: "#d42155",
      'stroke-width' => 5,
      'stroke-opacity' => 0.5,
    }
    geojson = CGI.escape({
      type: 'FeatureCollection',
      features: [f]
    }.to_json)

    puts name
    File.open(file, 'w') do |png|
      png << open(url % geojson).read
    end
  end
end