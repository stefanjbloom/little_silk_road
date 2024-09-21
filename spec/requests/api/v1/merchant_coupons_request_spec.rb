require 'rails_helper'

RSpec.describe 'Merchant Coupons Endpoints:' do
  before(:each) do
    @merchant_1 = Merchant.create!(name: "Cheap Shoes")
    @merchant_2 = Merchant.create!(name: "Fancy Corgis")
    
    @real_human1 = Customer.create!(first_name: 'Ross', last_name: 'Ulbricht')
    @real_human2 = Customer.create!(first_name: 'Jack', last_name: 'Parsons')

    @invoice1 = Invoice.create!(customer_id: @real_human1.id, merchant_id: @merchant_1.id, status: 'shipped')
    @invoice2 = Invoice.create!(customer_id: @real_human2.id, merchant_id: @merchant_2.id, status: 'returned')

    @dice = Item.create!(name: 'DND Dice', description: 'Dungeons and Dragons', unit_price: 10.99, merchant_id: @merchant_1.id)
    @cursed_object = Item.create!(name: 'Annabelle', description: 'Haunted Doll', unit_price: 6.00, merchant_id: @merchant_1.id)
    @weedkiller = Item.create!(name: 'Roundup', description: 'Bad for plants', unit_price: 400.99, merchant_id: @merchant_2.id)

    @coupon1 = Coupon.create!(name: "10% Off", code: "Unique1", percent_off: 10, status: "activated", merchant: @merchant_1)
    @coupon2 = Coupon.create!(name: "20% Off", code: "Unique2", percent_off: 20, status: "activated", merchant: @merchant_1)
    @coupon3 = Coupon.create!(name: "30% Off", code: "Unique3", percent_off: 30, status: "activated", merchant: @merchant_1)
    @coupon4 = Coupon.create!(name: "40% Off", code: "Unique4", percent_off: 40, status: "activated", merchant: @merchant_1)
    @coupon5 = Coupon.create!(name: "50% Off", code: "Unique5", percent_off: 50, status: "activated", merchant: @merchant_1)
    @coupon6 = Coupon.create!(name: "10% Off", code: "Unique6", percent_off: 10, status: "deactivated", merchant: @merchant_2)
  end

  describe 'HTTP Requests:' do
    describe '#Show' do
      it 'Can get one coupon by id from a merchants id' do
        get "/api/v1/merchants/#{@merchant_1.id}/coupons/#{@coupon1.id}"

        expect(response).to be_successful

        merchant_coupon = JSON.parse(response.body, symbolize_names: true)[:data]

        expect(merchant_coupon[:id]).to eq(@coupon1.id.to_s)
      end

      it 'renders proper error if coupon id not found' do
        get "/api/v1/merchants/#{@merchant_1.id}/coupons/8987678677"

        expect(response).not_to be_successful
        expect(response.status).to eq 404

        error = JSON.parse(response.body, symbolize_names: true)

        expect(error[:error]).to eq("Coupon not found")
      end
    end
    
  end
end