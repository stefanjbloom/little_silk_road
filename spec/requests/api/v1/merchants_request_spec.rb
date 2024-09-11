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

    it 'can update a merchant name' do
      id = @KozeyGroup.id
      previous_name = @KozeyGroup.name
      merchant_params = {name: "Kozey Grove co."}
      headers = {"CONTENT_TYPE" => "application/json"}

      patch "/api/v1/merchants/#{id}", headers: headers, params: JSON.generate({merchant: merchant_params})
      updated_merchant = Merchant.find_by(id: id)

      expect(response).to be_successful
      expect(updated_merchant.name).to_not eq(previous_name)
      expect(updated_merchant.name).to eq("Kozey Grove co.")
    end
  end
end