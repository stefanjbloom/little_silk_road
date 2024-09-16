require "rails_helper"

RSpec.describe InvoiceItem, type: :model do
  describe 'relationships' do
    it { should belong_to(:invoice) }
    it { should belong_to (:item) }
  end

  describe 'validations' do
    it { should validate_presence_of(:item_id).with_message("is required")}
    it { should validate_presence_of(:invoice_id).with_message("is required")}
    it { should validate_presence_of(:unit_price).with_message("is required")}
    it { should validate_presence_of(:quantity).with_message("is required")}
    it { should validate_numericality_of(:item_id).with_message("must be valid")}
    it { should validate_numericality_of(:invoice_id).with_message("must be valid")}
    it { should validate_numericality_of(:quantity).with_message("must be valid")}
    it { should validate_numericality_of(:unit_price).with_message("must be valid")}
  end
end