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
  end

  describe 'HTTP Requests:' do
    describe '#Show' do
      it 'Can get one coupon by id from a merchants id' do
        get "/api/v1/merchants/#{@merchant_1.id}/coupons/#{@coupon1.id}"

        expect(response).to be_successful

        merchant_coupon = JSON.parse(response.body, symbolize_names: true)[:data]

        expect(merchant_coupon[:id]).to eq(@coupon1.id.to_s)
      end
      # Sad Path Test
      it 'Renders proper error if coupon id not found' do
        get "/api/v1/merchants/#{@merchant_1.id}/coupons/8987678677"

        expect(response).not_to be_successful
        expect(response.status).to eq 404

        error = JSON.parse(response.body, symbolize_names: true)

        expect(error[:error]).to eq("Coupon not found")
      end
    end

    describe '#Index' do
      it 'Can show all of a merchants coupons w/ correct data and attributes' do
        get "/api/v1/merchants/#{@merchant_1.id}/coupons"

        expect(response).to be_successful

        merchant_coupons = JSON.parse(response.body, symbolize_names: true)[:data]
        
        merchant_coupons.each do |merchant_coupon|
          expect(merchant_coupon).to have_key(:id)
          expect(merchant_coupon[:id]).to be_a(String)

          expect(merchant_coupon).to have_key(:type)
          expect(merchant_coupon[:type]).to be_a(String)
          expect(merchant_coupon[:type]).to eq("coupon")

          merchant_coupon = merchant_coupon[:attributes]
          expect(merchant_coupon).to have_key(:name)
          expect(merchant_coupon[:name]).to be_a(String)

          expect(merchant_coupon).to have_key(:code)
          expect(merchant_coupon[:code]).to be_a(String)

          expect(merchant_coupon).to have_key(:percent_off)
          expect(merchant_coupon[:percent_off]).to be_a(Integer)

          expect(merchant_coupon).to have_key(:status)
          expect(merchant_coupon[:status]).to be_a(String)

          expect(merchant_coupon).to have_key(:usage_count)
          expect(merchant_coupon[:usage_count]).to be_a(Integer)
        end
      end
    end

    describe '#Create' do
      it 'Can create a new coupon for a merchant' do
        test_coupon = {
          name: "Test10",
          code: "TestTEN",
          percent_off: 10,
          status: "activated"
        }

        headers = {"CONTENT_TYPE" => "application/json"}

        post "/api/v1/merchants/#{@merchant_2.id}/coupons", headers: headers, params: JSON.generate(coupon: test_coupon)

        expect(response).to be_successful

        new_coupon = JSON.parse(response.body, symbolize_names: true)[:data]

        expect(new_coupon[:attributes][:name]).to eq("Test10")
        expect(new_coupon[:attributes][:code]).to eq("TestTEN")
        expect(new_coupon[:attributes][:percent_off]).to eq 10
        expect(new_coupon[:attributes][:status]).to eq("activated")
      end
      # Sad Path
      it 'Will not allow a merchant to have more than 5 active coupons' do
        @coupon6 = Coupon.create(name: "10% Off", code: "Unique6", percent_off: 10, status: "activated", merchant: @merchant_1)

        expect(@coupon6.valid?).to be(false)
        expect(@coupon6.errors[:merchant]).to include("can only have 5 active coupons at a time")
        
        expect{Coupon.create!(name: "10% Off", code: "Unique6", percent_off: 10, status: "activated", merchant: @merchant_1)}
        .to raise_error(ActiveRecord::RecordInvalid, "Validation failed: Merchant can only have 5 active coupons at a time")

      end
    end
  end
end