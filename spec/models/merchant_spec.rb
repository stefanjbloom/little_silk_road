require "rails_helper"

RSpec.describe Merchant, type: :model do
  describe 'relationships' do
    it { should have_many(:items) }
    it { should have_many (:invoices) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name).with_message("Please enter a merchant name") }
    it { should validate_uniqueness_of(:name).with_message("This merchant has already been created")}
  end

end