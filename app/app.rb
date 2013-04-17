require 'sinatra'
require 'sass'
require 'yaml'
require 'hashie'
require 'stripe'
require_relative 'helpers'

before { load_yaml_into_hashie_variables }

set :views, :sass => 'views/sass', :haml => 'views', :default => 'views'

# Routing
get '/styles.css' do
  content_type 'text/css', :charset => 'utf-8'
  sass :styles
end

get '/' do
  @title  = "NIRD"
  haml :index
end

get '/:verb' do |verb|
  if %(build teach partner pay).include? verb.downcase
    @title  = "NIRD - We #{verb.capitalize}"
    haml verb.to_sym
  else
    redirect to('/')
  end
end

# Stripe Functionality
set :publishable_key, ENV['PUBLISHABLE_KEY']
set :secret_key, ENV['SECRET_KEY']

Stripe.api_key = settings.secret_key

post '/charge' do
  # Amount in cents
  money_pair = params[:post][:cost].split('.').map{ |value| value.to_i}

  @amount = money_pair[0]*100 + (money_pair[1] || 0)
  @amount = [@amount, 50].max

  customer = Stripe::Customer.create(
    :email => 'customer@example.com',
    :card  => params[:stripeToken]
  )

  charge = Stripe::Charge.create(
    :amount      => @amount,
    :description => 'Sinatra Charge',
    :currency    => 'usd',
    :customer    => customer.id
  )

  haml :charge
end

error Stripe::CardError do
  env['sinatra.error'].message
end

# Routing Continued
get '/*' do
  redirect to('/')
end

