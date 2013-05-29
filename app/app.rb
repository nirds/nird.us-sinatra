class NirdApp < Sinatra::Base
  require 'sinatra'
  require "sinatra/reloader" if development?
  require 'sass'
  require 'yaml'
  require 'hashie'
  require 'stripe'
  require 'money'
  helpers do
    def find_template(views, name, engine, &block)
      # http://www.sinatrarb.com/intro#Looking%20Up%20Template%20Files
      _, folder = views.detect { |k,v| engine == Tilt[k] }
      folder ||= views[:default]
      super(folder, name, engine, &block)
    end

    def load_yaml_into_hashie_variables
      Dir.glob("data/*.yml").each do |file|
        variable = /data\/(.*).yml/.match(file)[1]
        yaml     = YAML.load_file file

        yaml.each_value { |value| modify_strings value }
        instance_variable_set(:"@#{variable}", Hashie::Mash.new(yaml))
      end
    end

    def standardize_title(unique_title_portion)
      "NIRD - #{unique_title_portion}"
    end

    def ensure_minimum_cents(cents)
      [cents, 50].max
    end

    def extract_description(post_data)
      customer = post_data[:organization]
      project  = post_data[:project]
      invoice  = post_data[:invoice]
      "#{customer} - #{project} - #{invoice}"
    end

    def extract_stripe_customer(params)
      Stripe::Customer.create(email: params[:post][:email],
                              card:  params[:stripeToken] )
    end

    def create_charge(amount, customer, description)
      Stripe::Charge.create(amount:      amount,
                            customer:    customer.id,
                            description: description,
                            currency:    'usd' )
    end

    private
    def modify_strings(value)
      if    value.class == Hash   then value.each_value { |v| modify_strings v }
      elsif value.class == String then value.replace(soft_hyphenate value.to_s)
      end
    end

    def soft_hyphenate(string)
      if first_word(string).match(/\[.*\]/)
        string.split(" ")[1..-1].join(" ")
      else
        hh = Text::Hyphen.new(:language => 'en_us', :left => 2, :right => 2)
        string.split(" ").map{ |word| hh.visualize(word, "&shy;") }.join(" ")
      end
    end

    def first_word(string)
      string.split(" ")[0] ? string.split(" ")[0] : ""
    end
  end

  configure do
    set static: true
    set public_folder: 'public'
    set :views, sass: 'views/sass', haml: 'views', default: 'views'

    set :publishable_key, ENV['PUBLISHABLE_KEY']
    set :secret_key,      ENV['SECRET_KEY']

    Stripe.api_key = settings.secret_key
  end

  require 'text/hyphen'
  require 'pry'
  require 'split'

  before { load_yaml_into_hashie_variables }

  # Split A/B Testing
  enable :sessions
  helpers Split::Helper

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
