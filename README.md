# FoodOrder
Simple app that make food ordering easy usign authentication with GitHub.

### Installation

1. Download app
2. Install all gems
```
bundle install
```
3. Migrate database
```
rake db:migrate
```
4. Create GitHub app
5. Set up [figaro gem](https://github.com/laserlemon/figaro), to use ENV variables in development, in config/application.yml
````ruby
GITHUB_KEY: "Client ID"
GITHUB_SECRET: "Client Secret"
````
6.Change server path in public/app/app.js
````javascript
var serverUrl = "http://localhost:3000"; //development
````
7. Enjoy FoodOrder app

### CORS

Default CROS are liberal and also unsafe. You can change them in config/initializers/cors.rb

````ruby
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins '*'
    resource '*',
      :headers => :any,
      :expose  => ['access-token', 'expiry', 'token-type', 'uid', 'client'],
      :methods => [:get, :post, :options, :delete, :put]
  end
end
````
