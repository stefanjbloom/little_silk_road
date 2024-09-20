require 'rails_helper'

RSpec.describe 'Merchant Coupons Endpoints:' do
  before(:each) do
    @merchant_1 = Merchant.create!(name: "Cheap Shoes")
    @merchant_2 = Merchant.create!(name: "Fancy Corgis")
    
    @real_human1 = Customer.create!(first_name: 'Ross', last_name: 'Ulbricht')
    @real_human2 = Customer.create!(first_name: 'Jack', last_name: 'Parsons')

    @invoice1 = Invoice.create!(customer_id: @real_human1.id, merchant_id: @macho_man.id, status: 'shipped')
    @invoice2 = Invoice.create!(customer_id: @real_human2.id, merchant_id: @macho_man.id, status: 'returned')

    @dice = Item.create!(name: 'DND Dice', description: 'Dungeons and Dragons', unit_price: 10.99, merchant_id: @macho_man.id)
    @cursed_object = Item.create!(name: 'Annabelle', description: 'Haunted Doll', unit_price: 6.00, merchant_id: @macho_man.id)
    @weedkiller = Item.create!(name: 'Roundup', description: 'Bad for plants', unit_price: 400.99, merchant_id: @kozey_group.id)

    @coupon1 = Coupon.create!(name: "10% Off", code: "Unique1", percent_off: 10, status: "activated", merchant: @merchant_1)
    @coupon2 = Coupon.create!(name: "20% Off", code: "Unique2", percent_off: 20, status: "activated", merchant: @merchant_1)
    @coupon3 = Coupon.create!(name: "30% Off", code: "Unique3", percent_off: 30, status: "activated", merchant: @merchant_1)
    @coupon4 = Coupon.create!(name: "40% Off", code: "Unique4", percent_off: 40, status: "activated", merchant: @merchant_1)
    @coupon5 = Coupon.create!(name: "50% Off", code: "Unique5", percent_off: 50, status: "activated", merchant: @merchant_1)
    @coupon6 = Coupon.create!(name: "10% Off", code: "Unique6", percent_off: 10, status: "deactivated", merchant: @merchant_2)
  end

  describe 'HTTP Requests:' do
    
  end
end