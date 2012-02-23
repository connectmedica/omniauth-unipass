require 'omniauth/strategies/oauth2'
require 'base64'
require 'openssl'

module OmniAuth
  module Strategies
    class Unipass < OmniAuth::Strategies::OAuth2
      DEFAULT_SCOPE = 'email'

      option :name, 'unipass'

      option :client_options, {
          :site          => 'https://www.stworzonedlazdrowia.pl/',
          :api_site      => 'https://www.stworzonedlazdrowia.pl/api/1',
          :authorize_url => '/oauth2/authorize',
          :token_url     => '/oauth2/token'
      }

      option :token_params, {
          :parse => :query
      }

      option :access_token_options, {
          :header_format => 'OAuth %s',
          :param_name    => 'oauth_token'
      }

      option :authorize_options, [:scope, :display]

      uid { raw_info['id'] }

      info do
        {
            'first_name' => raw_info['first_name'],
            'last_name'  => raw_info['last_name']
        }
      end

      extra do
        {
            'raw_info' => raw_info
        }
      end

      def raw_info
        @raw_info ||= access_token.get("#{options[:api_site]}/me").parsed
      end

      def authorize_params
        super.tap do |params|
          params.merge!(:display => request.params['display']) if request.params['display']
          params.merge!(:state   => request.params['state'])   if request.params['state']
          params[:scope] ||= DEFAULT_SCOPE
        end
      end

    end
  end
end
