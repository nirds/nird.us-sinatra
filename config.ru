require 'rubygems'
require 'bundler/setup'
require 'sinatra/base'
require 'split/dashboard'

Bundler.require

require "./app/app"

run Rack::URLMap.new \
  "/"                => NirdApp.new,
  "/split_dashboard" => Split::Dashboard.new
