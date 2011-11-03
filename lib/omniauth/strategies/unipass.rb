require 'omniauth/oauth'
require 'multi_json'

module OmniAuth
  module Strategies
    class Unipass < OmniAuth::Strategies::OAuth2

      def initialize(app, client_id = nil, client_secret = nil, options = {}, &block)
        options   = options.dup
        name      = options.delete(:name)     || 'unipass'
        @site     = options.delete(:site)     || 'http://test.stworzonedlazdrowia.pl/'
        @api_site = options.delete(:api_site) || 'http://test.stworzonedlazdrowia.pl/api/1'

        client_options = {
          :site          => @site,
          :authorize_url => '/oauth2/authorize',
          :token_url     => '/oauth2/token'
        }.merge(options[:client_options] || {})

        super(app, name, client_id, client_secret, client_options, options, &block)
      end

      protected

      def auth_hash
        OmniAuth::Utils.deep_merge(super, {
          'uid'       => user_data['id'],
          'user_info' => user_info,
          'extra'     => {'user_hash' => user_data}
        })
      end

      def user_info
        {
          'first_name' => user_data['first_name'],
          'last_name'  => user_data['last_name']
        }
      end

      def user_data
        session[:access_token]            = @access_token.token
        session[:access_token_expires_at] = @access_token.expires_at
        session[:refresh_token]           = @access_token.refresh_token

        @data ||= MultiJson.decode(@access_token.get("#{@api_site}/me").response.env[:body])
      end

    end
  end
end
