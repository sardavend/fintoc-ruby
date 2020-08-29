require 'fintoc/resources/account'

RSpec.describe Fintoc::Account do
  let(:data) do
    {
      "id": 'Z6AwnGn4idL7DPj4',
      "name": 'Cuenta Corriente',
      "official_name": 'Cuenta Corriente Moneda Local',
      "number": '9530516286',
      "holder_id": '134910798',
      "holder_name": 'Jon Snow',
      "type": 'checking_account',
      "currency": 'CLP',
      "balance": {
        "available": 7_010_510,
        "current": 7_010_510,
        "limit": 7_510_510
      }
    }
  end
  let(:account) { Fintoc::Account.new(**data) }
  it 'create an instance of Account' do
    expect(account).to be_an_instance_of(Fintoc::Account)
  end

  it "print the account's holder_name, name, and balance when to_s is called" do
    expect(account.to_s)
      .to eq(
        "💰 #{data[:holder_name]}’s #{data[:name]} #{data[:balance][:available]} (#{data[:balance][:current]})"
      )
  end
end
