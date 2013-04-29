require 'sinatra'
require 'sass'
require 'yaml'
require 'hashie'
require 'stripe'
require 'money'
require_relative 'helpers'

before { load_yaml_into_hashie_variables }

set :views, :sass => 'views/sass', :haml => 'views', :default => 'views'

# Routing
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

def standardize_title( unique_title_portion )
  "NIRD - #{unique_title_portion}"
end

# Stripe Functionality

def ensure_minimum_cents( cents )
  [ cents, 50 ].max
end

def extract_description( post_data )
  customer = post_data[:organization]
  project  = post_data[:project]
  invoice  = post_data[:invoice]
  return "#{customer} - #{project} - #{invoice}"
end

def extract_stripe_customer( params )
  Stripe::Customer.create(
    :email => 'customer@example.com',
    :card  => params[:stripeToken]
  )
end

def create_charge(amount, customer, description)
  Stripe::Charge.create(
    :amount      => amount,
    :customer    => customer.id,
    :description => description,
    :currency    => 'usd'
  )
end

set :publishable_key, ENV['PUBLISHABLE_KEY']
set :secret_key, ENV['SECRET_KEY']

Stripe.api_key = settings.secret_key

post '/charge' do
  money       = Money.parse( params[:post][:cost] )
  amount      = ensure_minimum_cents( money.cents )
  customer    = extract_stripe_customer( params )
  description = extract_description( params[:post] )
  charge      = create_charge(amount, customer, description)

  @confirmed_charge = Money.us_dollar( charge.amount )
  @title            = "NIRD - Thank You"
  haml :charge
end

error Stripe::CardError do
  env['sinatra.error'].message
end

# Routing Continued
get '/*' do
  redirect to('/')
end

