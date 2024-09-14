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

    it '?status=returned should return merchants with items on returned invoice' do
      flustered_merchants = Merchant.status_returned('returned')
      expect(flustered_merchants).to eq([@macho_man, @liquor_store])
    end

    it '?count=true returns the store name and a count of its items' do
      item_count = Merchant.count_items("true")
      item_count_object = item_count.map do |merchant|
        {
          id: merchant.id.to_s,
          type: "merchant",
          attributes: {
            name: merchant.name,
            item_count: merchant.item_count.to_i
          }
        }
      end
      expected = {
        data: [
          {
            id: @macho_man.id.to_s,
              type: "merchant",
              attributes: {
                name: @macho_man.name,
                item_count: 1
              }
          },
          {
            id: @liquor_store.id.to_s,
              type: "merchant",
              attributes: {
                name: @liquor_store.name,
                item_count: 1
              }
          }
        ]
      }

      expect(data: item_count_object).to eq(expected)
    end
  end
end