require "rails_helper"

RSpec.describe Merchant, type: :model do
  describe 'relationships' do
    it { should have_many(:items) }
    it { should have_many(:invoices) }
    it { should have_many(:customers).through(:invoices)}
  end

  describe 'validations' do
    it { should validate_presence_of(:name).with_message("is required to create new Merchant") }
    it { should validate_uniqueness_of(:name).with_message("This merchant has already been created") }
  end
  
  before(:each) do
    @macho_man = Merchant.create!(name: "Randy Savage")
    @kozey_group = Merchant.create!(name: "Kozey Group")
    @liquor_store = Merchant.create!(name: "Liquor Store")
    @real_human1 = Customer.create!(first_name: 'Ross', last_name: 'Ulbricht')
    @real_human2 = Customer.create!(first_name: 'Jack', last_name: 'Parsons')  
    @dice = Item.create!(name: 'DND Dice', description: 'Dungeons and Dragons', unit_price: 10.99, merchant_id: @macho_man.id)
    @cursed_object = Item.create!(name: 'Annabelle', description: 'Haunted Doll', unit_price: 6.00, merchant_id: @liquor_store.id)  
    @invoice1 = Invoice.create!(customer_id: @real_human1.id, merchant_id: @macho_man.id, status: 'shipped')
    @invoice2 = Invoice.create!(customer_id: @real_human2.id, merchant_id: @macho_man.id, status: 'returned')   
    @invoice3 = Invoice.create!(customer_id: @real_human2.id, merchant_id: @liquor_store.id, status: 'returned')   
    @invoice_item1 = InvoiceItem.create!(item: @dice, invoice: @invoice1, quantity: 13, unit_price: 10.99 )
    @invoice_item2 = InvoiceItem.create!(item: @cursed_object, invoice: @invoice2, quantity: 1, unit_price: 6.00 )
  end

  describe 'Query Params' do

    it 'returns all merchants sorted by age' do
      sorted_age = Merchant.sort_by_age("age")
      expect(sorted_age).to eq([@liquor_store, @kozey_group, @macho_man])
    end
    
    it 'returns all merchants if ?status= is blank or invalid' do
      expect(Merchant.status_returned(nil)).to eq([@macho_man, @kozey_group, @liquor_store])
      expect(Merchant.status_returned("invalid")).to eq([@macho_man, @kozey_group, @liquor_store])
    end
    
    it "returns the store's name and a count of its items" do
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
    
    it 'returns all merchants if ?count= is blank or invalid' do
      expect(Merchant.count_items(nil).size).to eq(3)
      expect(Merchant.count_items("invalid").size).to eq(3)
    end
    
    it 'returns the results of a case-insensitive search' do
      expect(Merchant.search("Randy")).to eq(@macho_man)
      expect(Merchant.search("randy")).to eq(@macho_man)
    end
    
    it 'returns nil if ?name= does not match any merchant' do
      expect(Merchant.search("blahblah")).to eq(nil)
    end
    
    it 'returns all merchants if ?sorted= is blank or invalid' do
      expect(Merchant.sort_by_age(nil)).to eq([@macho_man, @kozey_group, @liquor_store])
      expect(Merchant.sort_by_age("invalid")).to eq([@macho_man, @kozey_group, @liquor_store])
    end
  end

  describe 'dependent: :destroy' do
    it 'destroys associated items and invoices when merchant is deleted' do
      @steve_the_pirate = Merchant.create!(name: "Steve The Pirate")
      @steve_the_pirate.destroy
      expect(Item.where(merchant_id: @steve_the_pirate.id).count).to eq(0)
      expect(Invoice.where(merchant_id: @steve_the_pirate.id).count).to eq(0)
    end
  end
end