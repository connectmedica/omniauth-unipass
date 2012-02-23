# OmniAuth Unipass &nbsp;[![Build Status](https://secure.travis-ci.org/connectmedica/omniauth-unipass.png)][travis]&nbsp;[![Dependency Status](https://gemnasium.com/connectmedica/omniauth-unipass.png?travis)][gemnasium]

Unipass OAuth2 Strategy for [OmniAuth 1.0](https://github.com/intridea/omniauth) authentication system.

Supports the OAuth 2.0 server-side flow.

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

Set up the strategy as a middleware in Ruby on Rails (eg. in `config/initializers/omniauth.rb`):

```ruby
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :unipass, ENV['UNIPASS_CLIENT_ID'], ENV['UNIPASS_CLIENT_SECRET']
end
```

...or if you are using [Devise-Omniauthable](https://github.com/plataformatec/devise/wiki/OmniAuth:-Overview) (inside your `config/initializers/devise.rb`):

```ruby
config.omniauth :unipass, ENV['UNIPASS_CLIENT_ID'], ENV['UNIPASS_CLIENT_SECRET']
```

## Configuration

You can set application-wide `scope` and `display` options:

```ruby
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :unipass, ENV['UNIPASS_CLIENT_ID'], ENV['UNIPASS_CLIENT_SECRET'],
    :display => 'popup',
    :scope   => 'email'
end
```

...or you can simply pass the `display` parameter for single request:

```ruby
link_to('Unipass Login', '/auth/unipass?display=mobile')
```

...or using Devise-Omniauthable helper:

```ruby
user_omniauth_authorize_path(:unipass, :display => :mobile)
```

Valid options for `display` parameter are:

* `popup` for streamlined fluid-width layout appropriate for popup windows.
* `mobile` for minimal, low-bandwidth layout appropriate for mobile devices.
* ...or leave it blank for standard full-screen layout.

## Client options

If you are testing your application using local (or test) Unipass server, you can customize the path using `client_options`:

```ruby
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :unipass, ENV['UNIPASS_CLIENT_ID'], ENV['UNIPASS_CLIENT_SECRET'],
    :client_options => {
      :site     => 'https://test.stworzonedlazdrowia.pl',      # Change it to your local Unipass server
      :api_site => 'https://test.stworzonedlazdrowia.pl/api/1' # Change it to your local Unipass API server
    }
```

## Auth Hash

Example of *Auth Hash* available via `request.env['omniauth.auth']`:

```ruby
{
  :provider => 'unipass',
  :id => 'ab123cd456ef',
  :info => {
    :name       => 'Stefan Tabory',
    :first_name => 'Stefan',
    :last_name  => 'Tabory',
    :location   => 'mazowieckie'
  },
  :credentials => {
    :token          => 'x_34D-Hd...', # OAuth 2.0 access_token, which you can store in session for later use in API client
    :refresh_token  => 'zGNMuLR-...', # OAuth 2.0 refresh_token, used to generate new access_tokens
    :expires_at     => 1321747205,    # when the access token expires (if it expires)
    :expires        => true           # if you request `offline_access` this will be false
  },
  :extra => {
    :raw_info => {
      :date_of_birth => '1978-11-24',
      :first_name    => 'Stefan',
      :last_name     => 'Tabory',
      :province      => 'mazowieckie',
      :sex           => false,
      :name          => 'Stefan Tabory',
      :id            => 'ab123cd456ef',
      :admin         => true
    }
  }
}
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Credits

A big credits go to the authors of [mkdynamic/omniauth-facebook](https://github.com/mkdynamic/omniauth-facebook), on which this strategy is based.
