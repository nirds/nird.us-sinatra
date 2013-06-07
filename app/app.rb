require 'sinatra'
require "sinatra/reloader" if development?
require 'sass'
require 'yaml'
require 'hashie'
require 'stripe'
require 'money'
require 'text/hyphen'
require_relative 'helpers'
require 'pry'
require 'split'

class NirdApp < Sinatra::Base
  helpers Sinatra::NirdHelpers

  helpers Split::Helper
  enable :sessions

  stripe_keys = YAML.load(File.read("secrets.yml"))[:stripe]

  configure do
    
    set static: true
    set public_folder: 'public'
    set :views, sass: 'views/sass', haml: 'views', default: 'views'

    set :publishable_key, stripe_keys[:publishable]
    set :secret_key,      stripe_keys[:secret]

    Stripe.api_key = settings.secret_key
  end

  before { load_yaml_into_hashie_variables }

  get '/styles.css' do
    content_type 'text/css', :charset => 'utf-8'
    sass :styles
  end

  get '/:verb' do |verb|
    verb_down = verb.downcase
    pass unless @offerings.has_key?( verb_down )
    @title = standardize_title( @offerings[verb_down].tagline )
    haml verb_down.to_sym
  end

  get '/:person' do |person|
    person_down = person.downcase
    pass unless @people.has_key?( person_down )
    @person = @people[person_down]
    @title = @person.full_name
    haml :person
  end

  get '/' do
    @title  = "NIRD"
    haml :index
  end

  post '/charge' do
    money       = Money.parse params[:post][:cost]
    amount      = ensure_minimum_cents    money.cents
    customer    = extract_stripe_customer params
    description = extract_description     params[:post]
    charge      = create_charge(amount, customer, description)

    @confirmed_charge = Money.us_dollar charge.amount
    @title            = "NIRD - Thank You"
    haml :charge
  end

  error Stripe::CardError do
    env['sinatra.error'].message
  end

  get '/*' do
    redirect to('/')
  end
end
