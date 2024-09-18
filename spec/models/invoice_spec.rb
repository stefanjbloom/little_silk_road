require "rails_helper"

RSpec.describe Invoice, type: :model do
  describe 'relationships' do
    it { should belong_to(:merchant) }
    it { should belong_to(:customer) }
    it { should have_many(:transactions) }
    it { should have_many(:invoice_items) }
    it { should have_many(:items).through(:invoice_items) }
  end

  describe "validations" do
    it { should validate_presence_of(:merchant_id).with_message("is required")}
    it { should validate_presence_of(:customer_id).with_message("is required")}
    it { should validate_presence_of(:status).with_message("is required")}
    it { should validate_numericality_of(:merchant_id).with_message("valid id required")}
    it { should validate_numericality_of(:customer_id).with_message("valid id required")}
  end

  before(:each) do
    @macho_man = Merchant.create!(name: "Randy Savage")
    @kozey_group = Merchant.create!(name: "Kozey Group")
    @liquor_store = Merchant.create!(name: "Liquor Store")

    @real_human1 = Customer.create!(first_name: 'Ross', last_name: 'Ulbricht')
    @real_human2 = Customer.create!(first_name: 'Jack', last_name: 'Parsons')  

    @invoice1 = Invoice.create!(customer_id: @real_human1.id, merchant_id: @macho_man.id, status: 'shipped')
    @invoice2 = Invoice.create!(customer_id: @real_human2.id, merchant_id: @macho_man.id, status: 'returned')   
    @invoice3 = Invoice.create!(customer_id: @real_human2.id, merchant_id: @macho_man.id, status: 'returned')
    @invoice4 = Invoice.create!(customer_id: @real_human2.id, merchant_id: @macho_man.id, status: 'packaged')
  end

  describe "filtering invoices by status" do
    it 'returns all invoices' do
      invoices = Invoice.filter_by_status(nil)
      expect(invoices).to include(@invoice1, @invoice2, @invoice3)
      expect(invoices.count).to eq(4)
    end
    it 'returns invoices with the returned status' do
      returned_invoices = Invoice.filter_by_status('returned')
      expect(returned_invoices).to include(@invoice2, @invoice3)
      expect(returned_invoices).to_not include(@invoice1)
      expect(returned_invoices.count).to eq(2)
    end
    it 'returns invoices with the shipped status' do
      shipped_invoices = Invoice.filter_by_status('shipped')
      expect(shipped_invoices).to include(@invoice1)
      expect(shipped_invoices).to_not include(@invoice2, @invoice3)
      expect(shipped_invoices.count).to eq(1)
    end
    it 'returns invoices with the packaged status' do
      packaged_invoices = Invoice.filter_by_status('packaged')
      expect(packaged_invoices).to include(@invoice4)
      expect(packaged_invoices).to_not include(@invoice1, @invoice2, @invoice3)
      expect(packaged_invoices.count).to eq(1)
    end
  end
end