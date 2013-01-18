require 'sinatra'
require 'sass'
require 'yaml'
require 'hashie'
require_relative 'helpers'

before { load_yaml_into_hashie_variables }

set :views, :sass => 'views/sass', :haml => 'views', :default => 'views'

get '/styles.css' do
  content_type 'text/css', :charset => 'utf-8'
  sass :styles
end

get '/' do
  @title  = "NIRD"
  haml :index
end

get '/:verb' do |verb|
  if %(build teach partner).include? verb.downcase
    @title  = "NIRD - We #{verb.capitalize}"
    haml verb.to_sym
  else
    redirect to('/')
  end
end

get '/*' do
  redirect to('/')
end