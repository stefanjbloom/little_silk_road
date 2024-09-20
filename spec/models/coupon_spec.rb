require "rails_helper"

RSpec.describe Coupon, type: :model do
  describe 'relationships' do
    it { should belong_to(:merchant) }
    it { should have_many(:invoices) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name).with_message("is required to create new Coupon")}
  end
end