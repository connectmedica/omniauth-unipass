require 'spec_helper'
require 'omniauth-unipass'
require 'openssl'
require 'base64'

describe OmniAuth::Strategies::Unipass do
  before :each do
    @request = double('Request')
    @request.stub(:params) { {} }
    @request.stub(:cookies) { {} }

    @client_id = '123'
    @client_secret = '53cr3tz'
  end

  subject do
    args = [@client_id, @client_secret, @options].compact
    OmniAuth::Strategies::Unipass.new(nil, *args).tap do |strategy|
      strategy.stub(:request) { @request }
    end
  end

  it_should_behave_like 'an oauth2 strategy'

  describe '#client' do
    it 'has correct Unipass site' do
      subject.client.site.should eq('https://www.stworzonedlazdrowia.pl')
    end

    it 'has correct Unipass API site' do
      subject.client.options[:api_site].should eq('https://www.stworzonedlazdrowia.pl/api/1')
    end

    it 'has correct authorize url' do
      subject.client.options[:authorize_url].should eq('/oauth2/authorize')
    end

    it 'has correct token url' do
      subject.client.options[:token_url].should eq('/oauth2/token')
    end
  end

end
