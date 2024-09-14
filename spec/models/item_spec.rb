require "rails_helper"

RSpec.describe Item, type: :model do
  before (:each) do
    @merchant = Merchant.create!(name: "Booze Shop")
    @item1 = Item.create!(name: "well whiskey", description: "cheap whiskey", unit_price: 10.00, merchant: @merchant)
    @item2 = Item.create!(name: "mid-range whiskey", description: "good whiskey", unit_price: 20.00, merchant: @merchant)
    @item3 = Item.create!(name: "top-shelf whiskey", description: "amazing whiskey", unit_price: 30.00, merchant: @merchant)

  end

  describe 'relationships' do
    it { should belong_to(:merchant) }
    it { should have_many(:invoice_items) }
    it { should have_many(:invoices).through(:invoice_items) }
  end
  describe 'validations' do
    it { should validate_presence_of(:name).with_message("is required")}
    it { should validate_presence_of(:description).with_message("is required")}
    it { should validate_presence_of(:unit_price).with_message("is required")}
    it { should validate_presence_of(:merchant_id).with_message("is required")}
    it { should validate_numericality_of(:unit_price).is_greater_than_or_equal_to(0).with_message("should be a valid price")}
  end
  describe '?Query Param' do
    it 'item?sorted=price should return items by price, cheapest first' do
      # @merchant = Merchant.create!(name: "Booze Shop")

      # @item1 = Item.create!(name: "well whiskey", description: "cheap whiskey", unit_price: 10.00, merchant: @merchant)
      # @item2 = Item.create!(name: "mid-range whiskey", description: "good whiskey", unit_price: 20.00, merchant: @merchant)
      # @item3 = Item.create!(name: "top-shelf whiskey", description: "amazing whiskey", unit_price: 30.00, merchant: @merchant)

      sorted_items = Item.order_by("price")
      
      expect(sorted_items).to eq([@item1, @item2, @item3])
    end
  end

  describe 'Search By Params' do
    it 'can return all items that meet the name criteria' do
      items = Item.search_by_params(name: "whiskey")
      expect(items.first).to eq(@item2)
      expect(items.last).to eq(@item1)
    end
  end
end