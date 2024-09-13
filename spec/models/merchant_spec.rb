require "rails_helper"

RSpec.describe Merchant, type: :model do
  describe 'relationships' do
    it { should have_many(:items) }
    it { should have_many (:invoices) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name).with_message("Please enter a merchant name") }
    it { should validate_uniqueness_of(:name).with_message("This merchant has already been created") }
  end

  describe '?Query Params' do
    before(:each) do
      @macho_man = Merchant.create!(name: "Randy Savage")
      @kozey_group = Merchant.create!(name: "Kozey Group")
      @liquor_store = Merchant.create!(name: "Liquor Store")
      @real_human1 = Customer.create!(first_name: 'Ross', last_name: 'Ulbricht')
      @real_human2 = Customer.create!(first_name: 'Jack', last_name: 'Parsons')  
      @illicit_goods = Item.create!(name: 'Contraband', description: 'Good Stuff', unit_price: 10.99, merchant_id: @macho_man.id)
      @cursed_object = Item.create!(name: 'Annabelle', description: 'Haunted Doll', unit_price: 6.66, merchant_id: @liquor_store.id)  
      @invoice1 = Invoice.create!(customer_id: @real_human1.id, merchant_id: @macho_man.id, status: 'shipped')
      @invoice2 = Invoice.create!(customer_id: @real_human2.id, merchant_id: @macho_man.id, status: 'returned')   
      @invoice3 = Invoice.create!(customer_id: @real_human2.id, merchant_id: @liquor_store.id, status: 'returned')   
      @invoice_item1 = InvoiceItem.create!(item: @illicit_goods, invoice: @invoice1, quantity: 13, unit_price: 10.99 )
      @invoice_item2 = InvoiceItem.create!(item: @cursed_object, invoice: @invoice2, quantity: 1, unit_price: 6.66 )
    end

    it '?sorted=age should return ascending by when created' do
      sorted_age = Merchant.sort_by_age("age")
      expect(sorted_age).to eq([@liquor_store, @kozey_group, @macho_man])

    end

    xit '?status=returned should return merchants with items on returned invoice' do
      flustered_merchants = Merchant.status_returned('returned')
      expect(flustered_merchants).to eq([@liquor_store, @macho_man])
    end

    xit '?count=true returns the store name and a count of its items' do
      item_count = Merchant.count_items(true)
      expected = {
        "data": [
          {
            "id": "1",
              "type": "merchant",
              "attributes": {
                "name": "Randy Savage",
                "item_count": 13
              }
          },
          {
            "id": "2",
              "type": "merchant",
              "attributes": {
                "name": "Kozey Group",
                "item_count": 0
              }
          },
          {
            "id": "3",
            "type": "merchant",
            "attributes": {
              "name": "Liquor Store",
              "item_count": 1
            }
          }
        ]
      }

      expect(item_count).to eq(expected)
    end
  end

end