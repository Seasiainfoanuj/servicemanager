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

* copy sample configs

```
cp config/database.example.yml config/database.yml
cp .env.sample .env
```

* restore DB from a backup

```
bundle exec rake db:drop db:create
bundle exec rails db < ~/bus4x4-sm-mysql.sql
bundle exec rake opscare:data:mangle # renames email address to prevent accidental mailing to clients
```

* OR setup database

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

## Misc


* retrieve a DB dump

```
sentinel list staging --profile bus4x4-sm # list of instances and their IPs

ssh app_user@WEB_IP_ADDR
mysqldump --single-transaction -C -u $DBUSER -h $DBHOST --password=$DBPASSWORD $DBNAME | gzip > bus4x4-sm-mysql.sql.gz

# your pc
scp app_user@WEB_IP_ADDR:~/bus4x4-sm-mysql.sql.gz

# dont forget to delete the dump file from the instance!
```
