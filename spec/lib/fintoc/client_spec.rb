require 'fintoc/client'
require 'fintoc/resources/link'
require 'fintoc/resources/account'
require 'fintoc/resources/movement'

RSpec.describe Fintoc::Client do
  let(:api_key) { 'sk_test_9c8d8CeyBTx1VcJzuDgpm4H-bywJCeSx' }
  let(:link_token) {'6n12zLmai3lLE9Dq_token_gvEJi8FrBge4fb3cz7Wp856W'}
  let(:client) { Fintoc::Client.new(api_key) }

  it 'create an instance Client' do
    expect(client).to be_an_instance_of(Fintoc::Client)
  end

  context 'Client - API Interactions' do
    let(:link) { client.link(link_token) }
    let(:account) { link.find(type: 'checking_account') }
    it 'get the link from a given link token' do
      expect(link).to be_an_instance_of(Fintoc::Link)
    end
    it 'get a valid account' do
      expect(account).to be_an_instance_of(Fintoc::Account)
    end
    it "get account's movements without arguments" do
      movements = account.movements
      expect(movements.size).to be <= 30
      expect(movements).to all(be_a(Fintoc::Movement))
    end
    it "get account's movements with arguments" do
      movements = account.movements(since: '2020-08-15')
      account.show_movements
      expect(movements).to all(be_a(Fintoc::Movement))
    end

    it "update account's movements" do
      movements = account.movements(since: '2020-08-15')
      account.update_balance
      expect(movements).to all(be_a(Fintoc::Movement))
    end

  end
end
