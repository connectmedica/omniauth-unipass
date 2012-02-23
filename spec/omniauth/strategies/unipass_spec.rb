require 'spec_helper'
require 'omniauth-unipass'
require 'openssl'
require 'base64'

describe OmniAuth::Strategies::Unipass do
  before :each do
    @request = double('Request')
    @request.stub(:params){ {} }
    @request.stub(:cookies){ {} }

    @client_id     = '33ade5204037012f84783c075443e018'
    @client_secret = '47380fc04037012f84783c075443e018'
  end

  subject do
    args = [@client_id, @client_secret, @options].compact
    OmniAuth::Strategies::Unipass.new(nil, *args).tap do |strategy|
      strategy.stub(:request){ @request }
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

  describe '#callback_url' do
    it "returns value from #authorize_options" do
      url = 'http://myapp.example.com/users/oauth2/callbacks/uni'
      @options = {:authorize_options => {:callback_url => url}}
      subject.callback_url.should eq(url)
    end

    it "callback_url from request" do
      url_base = 'http://myapp.example.com'
      @request.stub(:url){ "#{url_base}/page/path" }
      subject.stub(:script_name){ '' } # to not depend from Rack env
      subject.callback_url.should eq("#{url_base}/auth/unipass/callback")
    end
  end

  describe '#authorize_params' do
    it 'includes default scope for email access' do
      subject.authorize_params.should be_a(Hash)
      subject.authorize_params[:scope].should eq('email')
    end

    it 'includes display parameter from request when present' do
      @request.stub(:params){ {'display' => 'mobile'} }
      subject.authorize_params.should be_a(Hash)
      subject.authorize_params[:display].should eq('mobile')
    end

    it 'includes state parameter from request when present' do
      @request.stub(:params){ {'state' => 'my_state'} }
      subject.authorize_params.should be_a(Hash)
      subject.authorize_params[:state].should eq('my_state')
    end
  end

  describe '#access_token_options' do
    it 'has correct param name by default' do
      subject.access_token_options[:param_name].should eq('oauth_token')
    end

    it 'has correct header format by default' do
      subject.access_token_options[:header_format].should eq('Bearer %s')
    end
  end

  describe '#uid' do
    before :each do
      subject.stub(:raw_info){ {'id' => 'unipass-randomrandom'} }
    end

    it 'returns the id from raw_info' do
      subject.uid.should eq('unipass-randomrandom')
    end
  end

  describe '#info' do
    before :each do
      @raw_info ||= {'first_name' => 'Bob'}
      subject.stub(:raw_info){ @raw_info }
    end

    context 'when data is not present in raw info' do
      it 'has nil last_name key' do
        subject.info.should have_key('last_name')
        subject.info['last_name'].should be_nil
      end
    end

    context 'when data is present in raw info' do
      it 'returns the first_name' do
        subject.info['first_name'].should eq('Bob')
      end

      it 'returns the last_name' do
        @raw_info['last_name'] = 'Gedlof'
        subject.info['last_name'].should eq('Gedlof')
      end
    end
  end

  describe '#raw_info' do
    before :each do
      @access_token = double('OAuth2::AccessToken')
      subject.stub(:access_token){ @access_token }
    end

    it 'performs a GET to https://www.stworzonedlazdrowia.pl/api/1/me' do
      @access_token.stub(:get){ double('OAuth2::Response').as_null_object }
      @access_token.should_receive(:get).with('/me')
      subject.raw_info
    end

    it 'returns a Hash' do
      @access_token.stub(:get).with('/me') do
        raw_response = double('Faraday::Response')
        raw_response.stub(:body){ '{ "spam": "ham" }' }
        raw_response.stub(:status){ 200 }
        raw_response.stub(:headers){ {'Content-Type' => 'application/json'} }
        OAuth2::Response.new(raw_response)
      end
      subject.raw_info.should be_a(Hash)
      subject.raw_info['spam'].should eq('ham')
    end
  end

  describe '#extra' do
    before :each do
      @raw_info = {'name' => 'Bob Gedlof'}
      subject.stub(:raw_info){ @raw_info }
    end

    it 'returns a Hash' do
      subject.extra.should be_a(Hash)
    end

    it 'contains raw info' do
      subject.extra.should eq({'raw_info' => @raw_info})
    end
  end

  describe '#credentials' do
    before :each do
      @access_token = double('OAuth2::AccessToken')
      @access_token.stub(:token)
      @access_token.stub(:expires?)
      @access_token.stub(:expires_at)
      @access_token.stub(:refresh_token)
      subject.stub(:access_token){ @access_token }
    end

    it 'returns a Hash' do
      subject.credentials.should be_a(Hash)
    end

    it 'returns the token' do
      @access_token.stub(:token){ 'UpU312ZrZIx2-WSt0tyB4YIcObGnhphN-eHSasQOWU6-Le6wj3hbR8bECiJIs_TbdaKiuqWMeFCpXTEo801DwReIvGRR9WVHH0n4yrAdjIkAhZoLI3n_4LgZeGCzhaGM' }
      subject.credentials['token'].should eq('UpU312ZrZIx2-WSt0tyB4YIcObGnhphN-eHSasQOWU6-Le6wj3hbR8bECiJIs_TbdaKiuqWMeFCpXTEo801DwReIvGRR9WVHH0n4yrAdjIkAhZoLI3n_4LgZeGCzhaGM')
    end

    it 'returns the expiry status' do
      @access_token.stub(:expires?){ true }
      subject.credentials['expires'].should eq(true)

      @access_token.stub(:expires?){ false }
      subject.credentials['expires'].should eq(false)
    end

    it 'returns the refresh token and expiry time when expiring' do
      ten_mins_from_now = (Time.now + 10 * 60).to_i
      @access_token.stub(:expires?){ true }
      @access_token.stub(:refresh_token){ 'yM9_7ltgVGTzxbF67sSjgJQz4r1ejE3nkOU63fXJ1ZFw_cst3z4XeEkovXRIAXvr4AmDhk36j1GYhVDbQ4KY4IoDNuix6y3eQGy57eBJaD3wpdplL12l8Q6srGtCD12P' }
      @access_token.stub(:expires_at){ ten_mins_from_now }
      subject.credentials['refresh_token'].should eq('yM9_7ltgVGTzxbF67sSjgJQz4r1ejE3nkOU63fXJ1ZFw_cst3z4XeEkovXRIAXvr4AmDhk36j1GYhVDbQ4KY4IoDNuix6y3eQGy57eBJaD3wpdplL12l8Q6srGtCD12P')
      subject.credentials['expires_at'].should eq(ten_mins_from_now)
    end

    it 'does not return the refresh token when it is nil and expiring' do
      @access_token.stub(:expires?){ true }
      @access_token.stub(:refresh_token){ nil }
      subject.credentials['refresh_token'].should be_nil
      subject.credentials.should_not have_key('refresh_token')
    end

    it 'does not return the refresh token when not expiring' do
      @access_token.stub(:expires?){ false }
      @access_token.stub(:refresh_token){ 'zM9_7ltgVGTzxbF67sSjgJQz4r1ejE3nkOU63fXJ1ZFw_cst3z4XeEkovXRIAXvr4AmDhk36j1GYhVDbQ4KY4IoDNuix6y3eQGy57eBJaD3wpdplL12l8Q6srGtCD12P' }
      subject.credentials['refresh_token'].should be_nil
      subject.credentials.should_not have_key('refresh_token')
    end
  end

end
