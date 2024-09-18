require "rails_helper"

RSpec.describe Customer, type: :model do
  describe 'relationships' do
    it { should have_many(:invoices) }
  end

  describe 'validations' do
    it { should validate_presence_of(:first_name).with_message("is required")}
    it { should validate_presence_of(:last_name).with_message("is required")}
  end
end