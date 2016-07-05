#encoding: utf-8
require 'json'

ENV['cwd'] = Dir.pwd

data = File.read('./polygon.geojson')
$polygon = JSON.parse(data, symbolize_names: true)[:features]
  .first[:geometry][:coordinates]
  .first.map(&:reverse)

CACHE ||= "#{ENV['cwd']}/tmp/cache.json"

Rake::TaskManager.record_task_metadata = true

$dir = File.expand_path File.dirname(__FILE__)

Dir["#{$dir}/bin/**.rb"].each do |f|
  require f
end