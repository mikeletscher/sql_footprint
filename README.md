# SqlFootprint [![Build Status](https://travis-ci.org/covermymeds/sql_footprint.svg?branch=master)](https://travis-ci.org/covermymeds/sql_footprint)

This gem allows you to keep a "footprint" of the sql queries that your application runs.
It's like logging all the sql you're executing except that we remove all the value parameters
and dedupe similar queries. This footprint should be valuable in determining if changes you've
made will significantly change the way you're querying the database.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'sql_footprint', group: [:development, :test]
```

And then execute:

    $ bundle

## Usage

Typically, you would want to run this while you're running your specs.
For example w/ RSpec:
```
RSpec.configure do |config|
  config.before(:suite) { SqlFootprint.start }
  config.after(:suite) { SqlFootprint.stop }
end
```

After running your specs you'll find a 'footprint.sql' file in your project.
Adding this to your Git repository can be very useful so you can include the diff of the footprint
as part of your code review.

DO NOT run SqlFootprint in production!
