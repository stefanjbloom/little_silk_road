require 'rails_helper'

RSpec.describe 'Merchant Endpoints:' do
  before (:each) do
    @macho_man = Merchant.create!(name: "Randy Savage")
    @kozey_group = Merchant.create!(name: "Kozey Group")
    @hot_topic = Merchant.create!(name: "Hot Topic")
    @real_human1 = Customer.create!(first_name: 'Ross', last_name: 'Ulbricht')
    @real_human2 = Customer.create!(first_name: 'Jack', last_name: 'Parsons')
    @dice = Item.create!(name: 'DND Dice', description: 'Dungeons and Dragons', unit_price: 10.99, merchant_id: @macho_man.id)
    @cursed_object = Item.create!(name: 'Annabelle', description: 'Haunted Doll', unit_price: 6.00, merchant_id: @macho_man.id)
    @weedkiller = Item.create!(name: 'Roundup', description: 'Bad for plants', unit_price: 400.99, merchant_id: @kozey_group.id)
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

  it 'Create a merchant' do
    expect(Merchant.count).to eq(3)

    merchant_params = {
      name: "Walter White"
    }

    post "/api/v1/merchants", params: merchant_params, as: :json

    expect(response).to be_successful
    expect(Merchant.count).to eq(4)

    new_merchant = Merchant.last
    expect(new_merchant.name).to eq(merchant_params[:name])
  end

  describe 'Return customers by merchant id' do
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
    xit "renders a JSON representation of all records of the requested resource" do
      get "/api/v1/merchants/#{@macho_man.id}/items"
      expect(response).to be_successful

      items = JSON.parse(response.body, symbolize_names: true)[:data]
      puts "Items structure: #{items.inspect}"
      item1 = items.find {|item| item[:id] == @dice.id.to_s}
      item2 = items.find {|item| item[:id] == @cursed_object.id.to_s}
      item3 = items.find {|item| item[:id] == @weedkiller.id.to_s}

      expect(items).to be_an(Array)
      expect(items.count).to eq(2)

      expect(item1[:attributes][:name]).to eq(@dice.name)
      expect(item1[:attributes][:description]).to eq(@dice.description)
      expect(item1[:attributes][:unit_price]).to eq(@dice.unit_price)
      expect(item2[:attributes][:name]).to eq(@cursed_object.name)
      expect(item2[:attributes][:description]).to eq(@cursed_object.description)
      expect(item2[:attributes][:unit_price]).to eq(@cursed_object.unit_price)
      
      expect(items).to eq([item1, item2])
      expect(items).to_not eq([item1, item2, item3])
    end
    xit "returns a 404 error if merchant is not found" do
      get "/api/v1/merchants/0/items"
      
      data = JSON.parse(response.body, symbolize_names: true)
      
      expect(response).to_not be_successful
      expect(response.status).to eq(404)

      expect(data[:errors]).to be_an(Array)
      expect(data[:errors][:status]).to eq("404")
      expect(data[:errors][:message]).to eq("Merchant not found")
    end
  end

  describe "Find Action" do
    it 'can find the first merchant to meet the params in alphabetical order' do
      store1 = Merchant.create!(name: "Amazon Storefront")
      store2 = Merchant.create!(name: "Amazing Store")

      get "/api/v1/merchants/find?name=Maz"
      data = JSON.parse(response.body, symbolize_names: true)[:data]

      expect(response).to be_successful
      expect(response.status).to eq(200)
      expect(data[:id]).to eq(store1.id.to_s)
      expect(data[:attributes][:name]).to eq(store1.name)
    end

    it 'will handle incorrect searches' do
      get "/api/v1/merchants/find?name=1234"
      data = JSON.parse(response.body, symbolize_names: true)

      expect(response).to_not be_successful
      expect(response.status).to eq(404)
      expect(data[:errors]).to be_a(Array)
      expect(data[:errors].first[:status]).to eq("404")
      expect(data[:errors].first[:title]).to eq("Merchant not found")
    end
  end

  describe 'sad path exception handlers' do
    it 'handles incorrect id parameter for #show' do
      get "/api/v1/merchants/1000"
      expect(response).to_not be_successful
      expect(response.status).to eq(404)
      data = JSON.parse(response.body, symbolize_names: true)

      expect(data[:errors]).to be_a(Array)
      expect(data[:errors].first[:status]).to eq("404")
      expect(data[:errors].first[:title]).to eq("Couldn't find Merchant with 'id'=1000")
    end

    it 'handles incorrect id parameter for #patch' do
      patch "/api/v1/merchants/2000", params: { merchant: { name: "Mr. Newname" } }

      expect(response).to_not be_successful
      expect(response.status).to eq(404)
      data = JSON.parse(response.body, symbolize_names: true)

      expect(data[:errors]).to be_a(Array)
      expect(data[:errors].first[:status]).to eq("404")
      expect(data[:errors].first[:title]).to eq("Couldn't find Merchant with 'id'=2000")
    end

    it 'handles incorrect id parameter for #delete' do
      delete "/api/v1/merchants/3000"

      expect(response).to_not be_successful
      expect(response.status).to eq(404)
      data = JSON.parse(response.body, symbolize_names: true)

      expect(data[:errors]).to be_a(Array)
      expect(data[:errors].first[:status]).to eq("404")
      expect(data[:errors].first[:title]).to eq("Couldn't find Merchant with 'id'=3000")
    end
  end

  describe 'Index Action' do
    xit 'Can sort merchants by age' do
      get "/api/v1/merchants?sorted=age"

      expect(response).to be_successful

      merchants = JSON.parse(response.body, symbolize_names: true)[:data]
      
      expect(merchants.first[:attributes][:name]).to eq(@kozey_group.name)
      expect(merchants.last[:attributes][:name]).to eq(@macho_man.name)
    end
    it 'Can display only merchants with invoice status="returned"' do
      
      get "/api/v1/merchants?status=returned"
      
      expect(response).to be_successful
      
      merchants = JSON.parse(response.body, symbolize_names: true)[:data]
      
      expect(merchants.first[:attributes][:name]).to eq(@macho_man.name)
      expect(merchants.first[:attributes][:name]).not_to eq([@kozey_group.name])
    end
    it 'Can display count of how many items a merchant has' do
      get "/api/v1/merchants?count=true"
      
      expect(response).to be_successful
      
      merchants = JSON.parse(response.body, symbolize_names: true)[:data]

      macho_man_response = merchants.find { |merchant| merchant[:id] == @macho_man.id.to_s }
      item_count = @macho_man.items.count
      
      expect(macho_man_response[:attributes][:item_count]).to eq(item_count)
    end
  end
end


    # POTENTIALLY USEFUL TESTING CODE - DELETE BEFORE SUBMISSION
    # context "it will always return data in an array" do
    #   it "even if only one resource is found" do
    #     get "/api/v1/merchants/#{@kozey_group.id}/items"
    #     expect(response).to be_successful
        
    #     items = JSON.parse(response.body, symbolize_names: true)[:data]
    #     item1 = items.find {|item| item[:id] == @dice.id.to_s}
    #     item2 = items.find {|item| item[:id] == @cursed_object.id.to_s}
    #     item3 = items.find {|item| item[:id] == @weedkiler.id.to_s}

    #     expect(items).to be_an(Array)
    #     expect(items.count).to eq(1)
    #   end

    #   it "or zero resources are found" do
    #     get "/api/v1/merchants/#{@hot_topic.id}/items"
    #     expect(response).to be_successful
        
    #     items = JSON.parse(response.body, symbolize_names: true)[:data]
    #     item1 = items.find {|item| item[:id] == @dice.id.to_s}
    #     item2 = items.find {|item| item[:id] == @cursed_object.id.to_s}
    #     item3 = items.find {|item| item[:id] == @weedkiller.id.to_s}

    #     expect(items).to be_an(Array)
    #     expect(items.count).to eq(0)
    #   end
    # end
    # context "when fetching a merchant's items"  do 
    #   it "the returned data does NOT include any data pertaining to dependants of the merchant's items" do

    #   end
