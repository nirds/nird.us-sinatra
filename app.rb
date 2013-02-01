require 'sinatra'
require 'sass'
require 'yaml'
require 'hashie'

set :views, :sass => 'views/sass', :haml => 'views', :default => 'views'

helpers do # http://www.sinatrarb.com/intro#Looking%20Up%20Template%20Files
  def find_template(views, name, engine, &block)
    _, folder = views.detect { |k,v| engine == Tilt[k] }
    folder ||= views[:default]
    super(folder, name, engine, &block)
  end
end

get '/styles.css' do
  content_type 'text/css', :charset => 'utf-8'
  sass :styles
end

get '/' do
  @title  = "NIRD"

  Dir.glob("data/*.yml").each do |file|
    variable = /data\/(.*).yml/.match(file)[1]
    instance_variable_set(:"@#{variable}", Hashie::Mash.new(YAML.load_file(file)))
  end

  haml :index
end

get '/build' do
  @title  = "NIRD - We Build"

  Dir.glob("data/*.yml").each do |file|
    variable = /data\/(.*).yml/.match(file)[1]
    instance_variable_set(:"@#{variable}", Hashie::Mash.new(YAML.load_file(file)))
  end

  haml :build
end

get '/teach' do
  @title  = "NIRD - We Teach"

  Dir.glob("data/*.yml").each do |file|
    variable = /data\/(.*).yml/.match(file)[1]
    instance_variable_set(:"@#{variable}", Hashie::Mash.new(YAML.load_file(file)))
  end

  haml :teach
end

get '/partner' do
  @title  = "NIRD - We Partner"

  Dir.glob("data/*.yml").each do |file|
    variable = /data\/(.*).yml/.match(file)[1]
    instance_variable_set(:"@#{variable}", Hashie::Mash.new(YAML.load_file(file)))
  end

  haml :partner
end

get '/debug' do
  @title  = "DEBUG PAGE"

  Dir.glob("data/*.yml").each do |file|
    variable = /data\/(.*).yml/.match(file)[1]
    instance_variable_set(:"@#{variable}", Hashie::Mash.new(YAML.load_file(file)))
  end

  haml :debug
end

get '/*' do
  redirect to('/')
end