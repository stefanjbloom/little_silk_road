require 'rails_helper'

RSpec.describe 'Merchant Invoices' do
  before(:each) do
    @macho_man = Merchant.create!(name: "Randy Savage")
    @kozey_group = Merchant.create!(name: "Kozey Group")
    @hot_topic = Merchant.create!(name: "Hot Topic")

    @real_human1 = Customer.create!(first_name: 'Ross', last_name: 'Ulbricht')
    @real_human2 = Customer.create!(first_name: 'Jack', last_name: 'Parsons')

    @dice = Item.create!(name: 'DND Dice', description: 'Dungeons and Dragons', unit_price: 10.99, merchant_id: @macho_man.id)
    @cursed_object = Item.create!(name: 'Annabelle', description: 'Haunted Doll', unit_price: 6.00, merchant_id: @macho_man.id)
    @weedkiller = Item.create!(name: 'Roundup', description: 'Bad for plants', unit_price: 400.99, merchant_id: @kozey_group.id)

    @invoice1 = Invoice.create!(customer_id: @real_human1.id, merchant_id: @macho_man.id, status: 'shipped')
    @invoice2 = Invoice.create!(customer_id: @real_human2.id, merchant_id: @macho_man.id, status: 'returned')
    @invoice3 = Invoice.create!(customer_id: @real_human1.id, merchant_id: @hot_topic.id, status: 'returned')
    @invoice4 = Invoice.create!(customer_id: @real_human2.id, merchant_id: @macho_man.id, status: 'packaged')
    
    @coupon1 = Coupon.create!(name: "Test 1", code: "Unique1", percent_off: 20, status: "activated", merchant: @macho_man)
    @coupon2 = Coupon.create!(name: "Test 2", code: "Unique2", percent_off: 10, status: "activated", merchant: @macho_man)
    @coupon3 = Coupon.create!(name: "Test 3", code: "Unique3", percent_off: 10, status: "activated", merchant: @macho_man)
    @coupon4 = Coupon.create!(name: "Test 4", code: "Unique4", percent_off: 30, status: "activated", merchant: @macho_man)
    @coupon5 = Coupon.create!(name: "Test 5", code: "Unique5", percent_off: 50, status: "activated", merchant: @macho_man)
  end

  describe 'HTTP Requests' do
    describe '#Show' do
      it 'can return merchants invoices and include coupon id' do
        
      end
    end
  end
end