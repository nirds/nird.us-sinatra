
To run the application in a development environment, run the following command.

  `bundle exec rackup config.ru`

Starting the application requires a secrets.yml file in your base directory, which looks something like this:

``` yaml
:split_dashboard:
  :username: "admin"
  :password: "dinosaurs sauce precinct fetch"
```

This file is ignored by git, and needs to be setup for production environments.
