# Service Manager 8.5.0

## repository

* [git@github.com:reinteractive/bus4x4.git](https://github.com/reinteractive/bus4x4.git)

## Dependencies

* Ruby 2.3.3
* Rails 4.2.7.1
* Mysql2

## setup

* clone repository

```
git clone git@github.com:reinteractive/bus4x4.git bus4x4-sm
cd bus4x4-sm
```

* install gems (first prepare your favourite ruby manager)

```
gem install bundler
bundle install
```

* setup database

```
bundle exec rails db:create db:schema:load
bundle exec rails db:seed # most of the seeds load... with some tweaking!
```

## Smoketest

```
bundle exec rails s
```

* navigate to localhost:3000
  - login: webmaster@bus4x4.com.au
  - password: password

## Run tests

```
bundle exec rake
```

## Deploy

* run deploy tool

```
git push origin staging
slingshot deploy staging --profile bus4x4-sm
```

