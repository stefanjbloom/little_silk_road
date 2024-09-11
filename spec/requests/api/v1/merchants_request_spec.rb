require 'rails_helper'

RSpec.describe 'Merchant Endpoints' do
  before (:each) do
    @MachoMan = Merchant.create!(name: "Randy Savage")
    @KozeyGroup = Merchant.create!(name: "Kozey Group")

  end
  describe 'HTTP Methods' do
    it 'Can retreive all merchants' do
      get "/api/v1/merchants"
      expect(response).to be_successful
      merchants = JSON.parse(response.body, symbolize_names: true)[:data]

      merchants.each do |merchant|

        expect(merchant).to have_key(:id)
        expect(merchant[:id]).to be_a(String)

        expect(merchant).to have_key(:type)
        expect(merchant[:type]).to eq("merchant")

        merchant = merchant[:attributes]

        expect(merchant).to have_key(:name)
        expect(merchant[:name]).to be_a(String)
      end
    end

    it 'Can retrieve one merchant' do
      get "/api/v1/merchants/#{@MachoMan.id}"
      expect(response).to be_successful
      merchant = JSON.parse(response.body, symbolize_names: true)[:data]

      expect(merchant).to have_key(:id)
      expect(merchant[:id]).to be_a(String)

      expect(merchant).to have_key(:type)
      expect(merchant[:type]).to eq("merchant")

      merchant = merchant[:attributes]

      expect(merchant).to have_key(:name)
      expect(merchant[:name]).to be_a(String)
    end
  end
end