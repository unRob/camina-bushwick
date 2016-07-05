desc 'Download all information from OSM'
task :source, :clear do |t, args|
  require 'open-uri'

  if !File.exist?(CACHE) || args[:clear]

    polygon = $polygon.flatten.join(' ')

    raw = open(%{http://overpass-api.de/api/interpreter?data=[out:json];way[highway](poly:"#{polygon}");out body;>;out skel geom qt;}).read
    File.open(CACHE, 'w') do |f|
      f << raw
    end
  end
end