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
    it 'Can Create a Merchant' do
      post "/api/v1/merchants", params: { merchant: { name: "Random Merchant" } }
      expect(response).to be_successful

      merchant_data = JSON.parse(response.body, symbolize_names: true)[:data]

      
      expect(merchant_data).to have_key(:id)
      expect(merchant_data[:id]).to be_a(String)
    
      expect(merchant_data).to have_key(:type)
      expect(merchant_data[:type]).to eq("merchant")
    
      merchant_attributes = merchant_data[:attributes]
    
      expect(merchant_attributes).to have_key(:name)
      expect(merchant_attributes[:name]).to eq("Random Merchant")
    end
  end
  describe 'Error Messages' do
    it 'returns proper error if there is a duplicate merchant' do
      post "/api/v1/merchants", params: { merchant: { name: "Randy Savage" } }
      post "/api/v1/merchants", params: { merchant: { name: "Randy Savage" } }
      expect(response).to have_http_status(422)

      error_message = JSON.parse(response.body, symbolize_names: true)[:errors][:name]
      expect(error_message).to eq(["This merchant has already been created"])
    end
    it 'returns proper error if there is no merchant name provided' do
      post "/api/v1/merchants", params: { merchant: { name: "" } }
      expect(response).to have_http_status(422)

      error_message = JSON.parse(response.body, symbolize_names: true)[:errors][:name]
      expect(error_message).to eq(["Please enter a merchant name"])
    end
  end
end