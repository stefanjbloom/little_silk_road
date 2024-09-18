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
      sorted_items = Item.order_by("price")
      expect(sorted_items).to eq([@item1, @item2, @item3])
    end
  end

  describe 'Search By Params' do
    it 'can return all items that meet the name criteria' do
      items = Item.search_by_params(name: "el")
      expect(items).to eq([@item3, @item1])
    end

    it 'can return all items above the minimum price' do
      items = Item.search_by_params(min_price: 20.00)
      expect(items).to eq([@item2, @item3])
    end

    it 'can return all items under the maximum price' do
      items = Item.search_by_params(max_price: 15.00)
      expect(items).to eq([@item1])
    end

    it 'can search for both minimum and maximum price together' do
      items = Item.search_by_params(min_price: 10.00, max_price: 20.00)
      expect(items).to eq([@item2, @item1])
    end

    it 'handles min_price and max_price under 0' do
      expect{
        Item.search_by_params(min_price: -1.00)
      }.to raise_error(ArgumentError, "price parameters cannot be less than 0")

      expect{
        Item.search_by_params(max_price: -1.00)
      }.to raise_error(ArgumentError, "price parameters cannot be less than 0")

      expect{
        Item.search_by_params(min_price: -1.00, max_price: -1.00)
      }.to raise_error(ArgumentError, "price parameters cannot be less than 0")
    end
  end
end