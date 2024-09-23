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
    @real_human1 = Customer.create!(first_name: 'Ross', last_name: 'Ulbricht')

  end

  describe 'Relationships' do
    it { should belong_to(:merchant) }
    it { should have_many(:invoices) }
  end

  describe 'Validations' do
    it { should validate_presence_of(:name).with_message("is required to create new Coupon")}
    it { should validate_presence_of(:code).with_message("is required to create new Coupon")}
    it { should validate_presence_of(:percent_off).with_message("is required to create new Coupon")}
    it { should validate_presence_of(:status).with_message("is required to create new Coupon")}
    it { should validate_numericality_of(:percent_off).with_message("should be a valid integer")}
    it { should validate_uniqueness_of(:code).with_message("coupon code must be unique")}
    it { should validate_inclusion_of(:status).in_array(["activated", "deactivated"])}
  end

  describe 'Custom Validation' do
    it 'should not allow more than 5 coupons per merchant' do
      @coupon6 = Coupon.new(name: "Test 6", code: "Unique6", percent_off: 20, status: "activated", merchant: @merchant)

      expect(@coupon6.valid?).to eq(false)
      expect(@coupon6.errors[:merchant]).to include("can only have 5 active coupons at a time")
    end
  end

  describe 'Class Methods' do
    describe '#create_a_coupon' do
      it 'can create a coupon object' do
        @couponMerch = Merchant.create!(name: "HiHeather")
        coupon_params = {name: "Test 6", code: "Unique6", percent_off: 20, status: "activated", merchant: @couponMerch}
        created_coupon = Coupon.create_a_coupon(@couponMerch, coupon_params)

        expect(created_coupon[:errors]).to be_nil
        expect(@couponMerch.coupons.count).to eq 1
        expect(created_coupon.name).to eq("Test 6")
      end

      it 'will not create a coupon and return proper error if merchant has 5 or more active coupons' do
        coupon_params = {name: "Test6", code: "Unique6", percent_off: 20, status: "activated", merchant: @merchant}
        created_coupon = Coupon.create_a_coupon(@merchant, coupon_params)

        expect(created_coupon[:errors]).to eq("Merchant can only have 5 active coupons")
        expect(@merchant.coupons.count).to eq 5
      end
    end

    describe '#change_status' do
      it 'can change a coupon status from "activated" to "deactivated and back' do
        Coupon.change_status(@merchant, @coupon1)

        expect(@coupon1.status).to eq("deactivated")

        Coupon.change_status(@merchant, @coupon1)

        expect(@coupon1.status).to eq("activated")
      end

      it 'will not deactivate coupon status if invoice is pending' do
        @invoice1 = Invoice.create!(customer_id: @real_human1.id, merchant_id: @merchant.id, coupon_id: @coupon1.id, status: 'pending')

        expect(@coupon1.status).to eq("activated")

        Coupon.change_status(@merchant, @coupon1)

        expect(@coupon1.status).to eq("activated")
      end
    end

    describe'#sort_by_status' do
      it 'can sort status correctly when query param ?sorted=active' do
        result = Coupon.sort_by_status("active")

        expect(result.count).to eq(5)
        expect(result).to include(@coupon1, @coupon2, @coupon3, @coupon4, @coupon5)
      end

      it 'can sort status correctly when query param ?sorted=inactive' do
        @couponMerch = Merchant.create!(name: "HiHeather")
        @inactive_coupon = Coupon.create!(name: "Inactive Coupon", code: "HIAbdul", percent_off: 20, status: "deactivated", merchant: @couponMerch)

        result = Coupon.sort_by_status("inactive")

        expect(result.count).to eq(1)
        expect(result).to include(@inactive_coupon)
      end

      it 'will return all coupons in absence of query param' do
        @couponMerch = Merchant.create!(name: "HiHeather")
        @inactive_coupon = Coupon.create!(name: "Inactive Coupon", code: "HIAbdul", percent_off: 20, status: "deactivated", merchant: @couponMerch)

        result = Coupon.sort_by_status("")

        expect(result.count).to eq(6)
        expect(result).to include(@coupon1, @coupon2, @coupon3, @coupon4, @coupon5, @inactive_coupon)
      end
    end
  end
end