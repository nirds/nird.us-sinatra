
require 'compass'
require 'sinatra'
require 'yaml'
require 'sass'

configure do # Based on Chris Eppstein's [Sinatra Integration](https://github.com/chriseppstein/compass/wiki/Sinatra-Integration)
  Compass.configuration do |config|
    config.project_path = File.dirname(__FILE__)
    config.sass_dir = 'views/sass'
  end

  set :haml, { :format => :html5 }
  set :sass, Compass.sass_engine_options
end

get '/screen.css' do
  content_type 'text/css', :charset => 'utf-8'
  sass :screen
end

get '/' do
  # TODO make this HAML
  @title  = "hello"
  @beers = YAML.load_file('data/beer.yml')
  @people = YAML.load_file('data/people.yml')
  @offerings = YAML.load_file('data/offerings.yml')
  haml :index
end

get '/teach' do
  haml :teach
end

get '/build' do
  haml :build
end

get '/partner' do
  haml :partner
end

get '/people' do
  haml :people
end

get '/people/%r{.*}' do |name|
  haml name
end


get '/*' do
  redirect to('/')
end