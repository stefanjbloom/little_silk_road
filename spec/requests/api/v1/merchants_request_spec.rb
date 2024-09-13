require 'rails_helper'

RSpec.describe 'Merchant Endpoints:' do
  before (:each) do
    @macho_man = Merchant.create!(name: "Randy Savage")
    @kozey_group = Merchant.create!(name: "Kozey Group")
    @hot_topic = Merchant.create!(name: "Hot Topic")
    @real_human1 = Customer.create!(first_name: 'Ross', last_name: 'Ulbricht')
    @real_human2 = Customer.create!(first_name: 'Jack', last_name: 'Parsons')
    @illicit_goods = Item.create!(name: 'Contraband', description: 'Good Stuff', unit_price: 10.99, merchant_id: @macho_man.id)
    @cursed_object = Item.create!(name: 'Annabelle', description: 'Haunted Doll', unit_price: 6.66, merchant_id: @macho_man.id)
    @weed = Item.create!(name: 'Alaskan Thunderfuck', description: 'terpy AF bruh lol', unit_price: 420.00, merchant_id: @kozey_group.id)
    @invoice1 = Invoice.create!(customer_id: @real_human1.id, merchant_id: @macho_man.id, status: 'shipped')
    @invoice2 = Invoice.create!(customer_id: @real_human2.id, merchant_id: @macho_man.id, status: 'returned')   
  end
  describe 'HTTP Methods' do
    it 'Can return all merchants' do
      get "/api/v1/merchants"
      expect(response).to be_successful
      merchants = JSON.parse(response.body, symbolize_names: true)[:data]

      merchants.each do |merchant|

        expect(merchant).to have_key(:id)
        expect(merchant[:id]).to be_a(String)

        expect(merchant).to have_key(:type)
        expect(merchant[:type]).to eq("merchant")

        merchant = merchant[:attributes]

        expect(merchant).to have_key(:name)
        expect(merchant[:name]).to be_a(String)
      end
    end

    it 'Can return one merchant' do
      get "/api/v1/merchants/#{@macho_man.id}"
      expect(response).to be_successful
      merchant = JSON.parse(response.body, symbolize_names: true)[:data]
      expect(merchant[:id]).to eq(@macho_man.id.to_s)
      expect(merchant[:attributes][:name]).to eq(@macho_man.name)
    end
  end

  describe 'return customers by merchant id' do
    it 'Can return all customers for a given merchant' do
      get "/api/v1/merchants/#{@macho_man.id}/customers"
      expect(response).to be_successful
      customers = JSON.parse(response.body, symbolize_names: true)[:data]
      customer1 = customers.find {|customer| customer[:id] == @real_human1.id.to_s}
      customer2 = customers.find {|customer| customer[:id] == @real_human2.id.to_s}

      expect(customers).to be_an(Array)
      expect(customers.count).to eq(2)
      expect(customer1).to have_key(:type)
      expect(customer1[:type]).to eq('customer')

      expect(customer1[:attributes]).to have_key(:first_name)
      expect(customer1[:attributes][:first_name]).to eq(@real_human1.first_name)
      expect(customer1[:attributes]).to have_key(:last_name)
      expect(customer1[:attributes][:last_name]).to eq(@real_human1.last_name)

      expect(customers).to eq([customer1, customer2])
    end

    it 'Returns empty array for customerless merchant' do
      really_bad_salesman = Merchant.create!(name: 'Arthur Miller')

      get "/api/v1/merchants/#{really_bad_salesman.id}/customers"
      expect(response).to be_successful
      customers = JSON.parse(response.body, symbolize_names: true)[:data]

      expect(customers).to eq([])
    end
  end

  describe 'Update Action' do
    it 'can update a merchant name' do
      id = @kozey_group.id
      previous_name = @kozey_group.name
      merchant_params = {name: "Kozey Grove co."}
      headers = {"CONTENT_TYPE" => "application/json"}

      patch "/api/v1/merchants/#{id}", headers: headers, params: JSON.generate({merchant: merchant_params})
      updated_merchant = Merchant.find_by(id: id)

      expect(response).to be_successful
      expect(updated_merchant.name).to_not eq(previous_name)
      expect(updated_merchant.name).to eq("Kozey Grove co.")
    end
  end

  describe 'Destroy Action' do
    it 'can delete a merchant and all of their items' do
      item = Item.create!(name: "Item", description: "This is an item", unit_price: 99.99, merchant_id: @macho_man.id)

      expect{ delete "/api/v1/merchants/#{@macho_man.id}" }.to change(Merchant, :count).by(-1)
      expect(Item.where(merchant_id: @macho_man.id).count).to eq(0)
      expect{ Merchant.find(@macho_man.id) }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe "Get all of a merchant's items by the merchant's id" do
    it "renders a JSON representation of all records of the requested resource" do
      get "/api/v1/merchants/#{@macho_man.id}/items"
      expect(response).to be_successful

      items = JSON.parse(response.body, symbolize_names: true)[:data]
      item1 = items.find {|item| item[:id] == @illicit_goods.id.to_s}
      item2 = items.find {|item| item[:id] == @cursed_object.id.to_s}
      item3 = items.find {|item| item[:id] == @weed.id.to_s}

      expect(items).to be_an(Array)
      expect(items.count).to eq(2)

      # expect(item1).to have_key(:type)
      # expect(item1[:type]).to eq('item')

      expect(item1[:attributes][:name]).to eq(@illicit_goods.name)
      expect(item1[:attributes][:description]).to eq(@illicit_goods.description)
      expect(item1[:attributes][:unit_price]).to eq(@illicit_goods.unit_price)
      expect(item2[:attributes][:name]).to eq(@cursed_object.name)
      expect(item2[:attributes][:description]).to eq(@cursed_object.description)
      expect(item2[:attributes][:unit_price]).to eq(@cursed_object.unit_price)
      
      expect(items).to eq([item1, item2])
      expect(items).to_not eq([item1, item2, item3])
    end
    it "returns a 404 error if merchant is not found" do
      
    end
  end
end

    
    # context "it will always return data in an array" do
    #   it "even if only one resource is found" do
    #     get "/api/v1/merchants/#{@kozey_group.id}/items"
    #     expect(response).to be_successful
        
    #     items = JSON.parse(response.body, symbolize_names: true)[:data]
    #     item1 = items.find {|item| item[:id] == @illicit_goods.id.to_s}
    #     item2 = items.find {|item| item[:id] == @cursed_object.id.to_s}
    #     item3 = items.find {|item| item[:id] == @weed.id.to_s}

    #     expect(items).to be_an(Array)
    #     expect(items.count).to eq(1)
    #   end

    #   it "or zero resources are found" do
    #     get "/api/v1/merchants/#{@hot_topic.id}/items"
    #     expect(response).to be_successful
        
    #     items = JSON.parse(response.body, symbolize_names: true)[:data]
    #     item1 = items.find {|item| item[:id] == @illicit_goods.id.to_s}
    #     item2 = items.find {|item| item[:id] == @cursed_object.id.to_s}
    #     item3 = items.find {|item| item[:id] == @weed.id.to_s}

    #     expect(items).to be_an(Array)
    #     expect(items.count).to eq(0)
    #   end
    # end
    # context "when fetching a merchant's items"  do 
    #   it "the returned data does NOT include any data pertaining to dependants of the merchant's items" do

    #   end