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
require 'mail'
require 'sinatra/formkeeper'

class NirdApp < Sinatra::Base
  register Sinatra::FormKeeper
  helpers Sinatra::NirdHelpers

  helpers Split::Helper
  enable :sessions

  stripe_keys = YAML.load(File.read("secrets.yml"))[:stripe]
  mandrill_keys = YAML.load(File.read("secrets.yml"))[:mandrill]

  configure do

    set static: true
    set public_folder: 'public'
    set :views, sass: 'views/sass', haml: 'views', default: 'views'

    set :publishable_key, stripe_keys[:publishable]
    set :secret_key,      stripe_keys[:secret]

    Stripe.api_key = settings.secret_key
  end

  Mail.defaults do
  delivery_method :smtp, {
    :port      => 587,
    :address   => "smtp.mandrillapp.com",
    :user_name => mandrill_keys[:user_name],
    :password  => mandrill_keys[:password]
    }
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

  get '/trainings' do
    haml :trainings
  end

  get '/advanced_bootcamp' do
    haml :advanced_bootcamp
  end

  post '/charge' do
    money       = Money.parse params[:cost]
    amount      = ensure_minimum_cents    money.cents
    customer    = extract_stripe_customer params
    description = extract_description     params
    charge      = create_charge(amount, customer, description)

    @confirmed_charge = Money.us_dollar charge.amount
    @title            = "NIRD - Thank You"
    haml :charge
  end

  get '/contact' do
    haml :contact
  end

  get '/style' do
    haml :style
  end
  
  post '/contact' do
    form do
      VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
      field :name, :present => true
      field :email, :present => true, :regexp => VALID_EMAIL_REGEX
      field :message, :present => true, :length => 5..250
    end

    if form.failed?
      output = haml :contact
      fill_in_form(output)
    else
      body = mail_body(params)
      contact_mailer(body)
      haml :contact_recieved
    end
  end


  error Stripe::CardError do
    env['sinatra.error'].message
  end

  get '/*' do
    redirect to('/')
  end
end
