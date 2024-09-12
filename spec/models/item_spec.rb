require "rails_helper"

RSpec.describe Item, type: :model do
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
end