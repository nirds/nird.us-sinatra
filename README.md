Before you can do anything, you now need to setup Redis (it is sortof like a database from the bizarro universe where Superman is evil and Lex Luther is a benevolent scientist)

Type this:
  'brew install redis'

Then turn it on with this:
  'redis-server /usr/local/etc/redis.conf'


To run the application in a development environment, run the following command.

  `bundle exec rackup config.ru`

Starting the application requires a secrets.yml file in your base directory, which looks something like this:

1) Make This File:
/nird.us-sinatra/secrets.yml

2) Insert this in it:
:split_dashboard:
  :username: "admin"
  :password: "dinosaurs sauce precinct fetch"
:stripe:
  :publishable: "pk_KRWWNieKEVApVZJvRndJSzbluAXq9"
  :secret: "Sf5wDKFm2URuJ6oLzTJXBoj4aOQTelm0"
:mandrill:
  :user_name: "info@nird.us"
  :password: "DoczGZMtJM9oZYMyYx-lEw"

Note that those nasty keys are actual stripe test keys, that will be visible on the test section of NIRD's stripe account.

This file is ignored by git, and needs to be setup for production environments.
