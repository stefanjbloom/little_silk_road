require 'rails_helper'

RSpec.describe 'Merchant Endpoints' do
  before (:each) do
    @macho_man = Merchant.create!(name: "Randy Savage")
    @kozey_group = Merchant.create!(name: "Kozey Group")
    @real_human = Customer.create!(first_name: 'Real', last_name: 'Human')
    @item1 = Item.create!(name: 'A', description: 'B', unit_price: 10.99, merchant_id: @macho_man.id)
    @invoice1 = Invoice.create!(customer_id: @real_human.id, merchant_id: @macho_man.id, status: 'shipped')
    InvoiceItem.create!(item_id: @item1.id, invoice_id: @invoice1.id, quantity: 3, unit_price: 10.99)
   
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
      get "/api/v1/merchants/#{@macho_man.id}" #ruby convention
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

    it 'Can retrieve all customers for a given merchant' do
      get "/api/v1/merchants/#{@macho_man.id}/customers" #ruby convention
      expect(response).to be_successful
      merchant = JSON.parse(response.body, symbolize_names: true)[:data]


    end
  end
end