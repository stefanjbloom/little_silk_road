require "rails_helper"

RSpec.describe Coupon, type: :model do
  before(:each) do
    @merchant = Merchant.create!(name: "Test Merchant")
    @coupon1 = Coupon.create!(name: "Test 1", code: "Unique1", percent_off: 20, status: "activated", merchant: @merchant)
    @coupon2 = Coupon.create!(name: "Test 2", code: "Unique2", percent_off: 10, status: "activated", merchant: @merchant)
    @coupon3 = Coupon.create!(name: "Test 3", code: "Unique3", percent_off: 10, status: "activated", merchant: @merchant)
    @coupon4 = Coupon.create!(name: "Test 4", code: "Unique4", percent_off: 30, status: "activated", merchant: @merchant)
    @coupon5 = Coupon.create!(name: "Test 5", code: "Unique5", percent_off: 50, status: "activated", merchant: @merchant)
    # @coupon6 = Coupon.create!(name: "Test 6", code: "Unique6", percent_off: 20, status: "activated", merchant: @merchant)
  end

  describe 'relationships' do
    it { should belong_to(:merchant) }
    it { should have_many(:invoices) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name).with_message("is required to create new Coupon")}
    it { should validate_presence_of(:code).with_message("is required to create new Coupon")}
    it { should validate_presence_of(:percent_off).with_message("is required to create new Coupon")}
    it { should validate_presence_of(:status).with_message("is required to create new Coupon")}
    it { should validate_numericality_of(:percent_off).with_message("should be a valid integer")}
    it { should validate_uniqueness_of(:code).with_message("coupon code must be unique")}
    it { should validate_inclusion_of(:status).in_array(["activated", "deactivated"])}
  end

  describe 'custom validation' do
    it 'should not allow more than 5 coupons per merchant' do
      @coupon6 = Coupon.new(name: "Test 6", code: "Unique6", percent_off: 20, status: "activated", merchant: @merchant)

      expect(@coupon6.valid?).to eq(false)
      expect(@coupon6.errors[:merchant]).to include("can only have 5 active coupons at a time")
    end
  end
end