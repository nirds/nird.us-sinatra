require 'rubygems'
require 'bundler/setup'
require 'sinatra/base'
require 'split/dashboard'

Bundler.require

require "./app/app"

secrets = YAML.load(File.read("secrets.yml"))
Split::Dashboard.use Rack::Auth::Basic do |username, password|
  username == secrets[:split_dashboard][:username]
  password == secrets[:split_dashboard][:password]
end

run Rack::URLMap.new \
  "/"                => NirdApp.new,
  "/split_dashboard" => Split::Dashboard.new

