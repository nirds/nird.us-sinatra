require 'sinatra'
require 'yaml'

before do
  headers "Content-Type" => "text/html; charset=utf-8"
end

set :views, :sass => 'views/sass', :default => 'views'

get '/' do
  # TODO make this HAML
  @title  = "hello"
  @beers = YAML.load_file('data/beer.yml')
  @people = YAML.load_file('data/people.yml')
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