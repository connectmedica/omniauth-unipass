require 'omniauth/strategies/oauth2'
require 'base64'
require 'openssl'

module OmniAuth
  module Strategies
    class Unipass < OmniAuth::Strategies::OAuth2
      DEFAULT_SCOPE = 'email'

      option :client_options, {
          :site          => 'https://www.stworzonedlazdrowia.pl',
          :api_site      => 'https://www.stworzonedlazdrowia.pl/api/1',
          :authorize_url => '/oauth2/authorize',
          :token_url     => '/oauth2/token'
      }

      option :access_token_options, {
          :param_name => 'oauth_token'
      }

      option :authorize_options, [:scope, :display]

      uid { raw_info['id'] }

      info do
        {
            'name'       => raw_info['name'],
            'first_name' => raw_info['first_name'],
            'last_name'  => raw_info['last_name'],
            'location'   => raw_info['province']
        }
      end

      extra do
        {
            'raw_info' => raw_info
        }
      end

      def raw_info
        @raw_info ||= access_token.get("#{options[:client_options][:api_site]}/me").parsed
      end

      def callback_url
        if options.authorize_options.respond_to?(:callback_url)
          options.authorize_options.callback_url
        else
          super
        end
      end

      def authorize_params
        super.tap do |params|
          params.merge!(:display => request.params['display']) if request.params['display']
          params.merge!(:state   => request.params['state'])   if request.params['state']
          params[:scope] ||= DEFAULT_SCOPE
        end
      end

      def access_token_options
        options.access_token_options.inject({}){ |h,(k,v)| h[k.to_sym] = v; h }
      end

    end
  end
end
