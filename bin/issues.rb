desc 'Generates issues for repo'


def crossings cross_streets, features
  cross_streets.map { |name|
    id, _ = features.find {|_, f| f[:name] == name }
    "  - [#{name}](#{id})"
  }
end

def issue_body feature, features
  <<-MD
![#{feature[:name]}](https://rob.mx/camina/bushwick/#{feature[:id]}.png)

- Longitud: #{feature[:length]}
- Conexiones:
#{crossings(feature[:crosses], features).join("\n")}

MD
end

task :issues, :repo do |t, args|
  require 'octokit'
  require 'json'

  features = JSON.parse(File.read('./tmp/streets.geojson'), symbolize_names: true)[:features].map { |f| [f[:properties][:id], f[:properties]] }.to_h

  github = Octokit::Client.new(access_token: ENV['GITHUB'])
  repo = args[:repo]

  created = []

  github.issues(repo, per_page: 100).each do |i|
    feature = features[i.number]
    created << i.number
    next if i.title == feature[:name]

    puts "Updating ##{i.number} #{i.title} to #{feature[:name]}"

    github.update_issue(repo, i.number, feature[:name], issue_body(feature, features))
    created << i.number
  end

  features.reject {|i, f| created.include? i }.each do |id, f|
    puts "Creating #{f[:name]}"
    github.create_issue(repo, f[:name], issue_body(f, features))
    sleep(5)
  end

end