require "rails_helper"

RSpec.describe Invoice, type: :model do
  describe 'relationships' do
    it { should belong_to(:merchant) }
    it { should belong_to(:customer) }
    it { should have_many(:transactions) }
    it { should have_many(:invoice_items) }
    it { should have_many(:items).through(:invoice_items) }
  end

  describe 'validations' do
    it { should validate_presence_of(:status).with_message("is required")}
    it { should validate_presence_of(:customer_id).with_message("is required")}
    it { should validate_presence_of(:merchant_id).with_message("is required")}
  end
end