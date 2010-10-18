require 'spec_helper'

describe AuctionHouse do
  before(:all) do
    @ah = AuctionHouse.new
  end

  describe 'config' do
    it 'should load the config' do
      @ah.config.should_not be_blank
    end

    it 'should have config values' do
      @ah.config['user_agent'].should_not be_blank
    end
  end

  describe 'login' do
    pending 'without authenticator'

    describe 'with authenticator' do
      before(:all) do
        @result = @ah.login!
      end

      it 'should login' do
        @result.should == @ah
      end

      it 'should login and need authenticator' do
        @result.needs_authenticator?.should == true
      end

      it 'should raise error with wrong code' do
        wrong_code = '11111111'
        lambda {@result.authenticate!(wrong_code)}.should raise_error([AuctionHouse::LoginError])
      end
    end
  end

  pending 'search'
end
