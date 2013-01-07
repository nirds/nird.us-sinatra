
require 'compass'
require 'sinatra'
require 'yaml'
require 'sass'

get '/styles.css' do
  content_type 'text/css', :charset => 'utf-8'
  sass :styles
end

get '/' do
  @title  = "hello"
  # TODO make YAML auto-load if it exist in data/
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