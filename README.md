# OmniAuth Unipass &nbsp;[![Build Status](https://secure.travis-ci.org/connectmedica/omniauth-unipass.png)][travis][![Dependency Status](https://gemnasium.com/connectmedica/omniauth-unipass.png?travis)][gemnasium]

This is the official OmniAuth strategy for authenticating to Unipass.

[travis]: http://travis-ci.org/connectmedica/omniauth-unipass
[gemnasium]: https://gemnasium.com/connectmedica/omniauth-unipass

## Installation

Add this line to your application's Gemfile:

    gem 'omniauth-unipass'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install omniauth-unipass

## Usage

```ruby
use OmniAuth::Builder do
  provider :unipas, ENV['CLIENT_ID'], ENV['CLIENT_SECRET']
end
```

More options:

```ruby
use OmniAuth::Builder do
  provider :unipas, ENV['CLIENT_ID'], ENV['CLIENT_SECRET'],
           :site     => ENV['SITE'],
           :api_site => ENV['API_SITE'],
           :setup    => true
end
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
