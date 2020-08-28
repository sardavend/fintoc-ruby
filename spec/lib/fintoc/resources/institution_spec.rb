require 'fintoc/resources/institution'

RSpec.describe Fintoc::Institution do
  let(:data) { { id: 'cl_banco_de_chile', name: 'Banco de Chile', country: 'cl'} }
  let(:institution) { Fintoc::Institution.new(**data)}
  it 'create an instance of Institution' do
    expect(institution).to be_an_instance_of(Fintoc::Institution)
  end
  it "returns the institution's name" do
    expect(institution.to_s).to eq("🏦 #{data[:name]}")

  end
end