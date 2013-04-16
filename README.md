# Glimpse::NewRelic

Glimpse.NewRelic is a gem which provides server-side data from Ruby apps to
the Glimpse client-side library. Think of it like Firebug for your server.

**This gem is currently experimental, and not directly supported by
either New Relic or Glimpse**

More information at http://getglimpse.com

## Installation

Add this line to your application's Gemfile:

    gem 'glimpse-new_relic'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install glimpse-new_relic

Glimpse.NewRelic requires the `newrelic_rpm` gem, and some features require
currently unreleased functionality. If you'd like to play, let us know and
we'll see if we can help get you running.

## Usage

Once Glimpse.NewRelic is installed in your application, web pages should show
an icon in the lower right. Click the icon to bring up the Glimpse panel,
and revel in the server-side data.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
