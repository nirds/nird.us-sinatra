configure do
  set static: true
  set public_folder: 'public'
  set :views, sass: 'views/sass', haml: 'views', default: 'views'

  set :publishable_key, ENV['PUBLISHABLE_KEY']
  set :secret_key,      ENV['SECRET_KEY']

  Stripe.api_key = settings.secret_key
end
