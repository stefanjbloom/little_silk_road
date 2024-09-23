require 'rails_helper'

RSpec.describe 'Merchant Invoices' do
  before(:each) do
    @invoice1 = Invoice.create!(customer_id: @real_human1.id, merchant_id: @macho_man.id, status: 'shipped')
    @invoice2 = Invoice.create!(customer_id: @real_human2.id, merchant_id: @macho_man.id, status: 'returned')
    @invoice3 = Invoice.create!(customer_id: @real_human1.id, merchant_id: @hot_topic.id, status: 'returned')
    @invoice4 = Invoice.create!(customer_id: @real_human2.id, merchant_id: @macho_man.id, status: 'packaged')

  end
end