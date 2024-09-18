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
    @invoice3 = Invoice.create!(customer_id: @real_human1.id, merchant_id: @hot_topic.id, status: 'returned')
    @invoice4 = Invoice.create!(customer_id: @real_human2.id, merchant_id: @macho_man.id, status: 'packaged')

  end

  describe "HTTP Methods" do
    it "Can return all merchants" do
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

    it "Can return one merchant" do
      get "/api/v1/merchants/#{@macho_man.id}"
      expect(response).to be_successful
      merchant = JSON.parse(response.body, symbolize_names: true)[:data]
      expect(merchant[:id]).to eq(@macho_man.id.to_s)
      expect(merchant[:attributes][:name]).to eq(@macho_man.name)
    end

    it "Can create a merchant" do
      expect(Merchant.count).to eq(3)

      merchant_params = {name: "Walter White"}
      post "/api/v1/merchants", params: merchant_params, as: :json
  
      expect(response).to be_successful
      expect(Merchant.count).to eq(4)
  
      new_merchant = Merchant.last
      expect(new_merchant.name).to eq(merchant_params[:name])
    end

    it "Can update a merchant's name" do
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

    it 'Can delete a merchant and all of their items' do
      item = Item.create!(name: "Item", description: "This is an item", unit_price: 99.99, merchant_id: @macho_man.id)

      expect{ delete "/api/v1/merchants/#{@macho_man.id}" }.to change(Merchant, :count).by(-1)
      expect(Item.where(merchant_id: @macho_man.id).count).to eq(0)
      expect{ Merchant.find(@macho_man.id) }.to raise_error(ActiveRecord::RecordNotFound)
    end
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

  describe "Get all of a merchant's items by the merchant's id" do
    it "renders a JSON representation of all records of a merchant's items" do
      get "/api/v1/merchants/#{@macho_man.id}/items"
      expect(response).to be_successful

      items = JSON.parse(response.body, symbolize_names: true)[:data]
  
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

    it "returns a 404 error if merchant is not found" do
      get "/api/v1/merchants/0/items"

      expect(response).to_not be_successful
      expect(response.status).to eq(404)

      data = JSON.parse(response.body, symbolize_names: true)

      expect(data[:errors]).to be_an(Array)
      expect(data[:message]).to eq("We could not complete your request, please enter new query.")
      expect(data[:errors]).to eq(["Couldn't find Merchant with 'id'=0"])
    end
  end

  describe "Get all of a merchant's invoices filtered by status" do
    context "renders a JSON representation of:" do
      it "all records of a merchant's invoices" do
        get "/api/v1/merchants/#{@macho_man.id}/invoices"
        expect(response).to be_successful
        invoices = JSON.parse(response.body, symbolize_names: true)[:data]
        invoice1 = invoices.find {|invoice| invoice[:id] == @invoice1.id.to_s}#shipped
        invoice2 = invoices.find {|invoice| invoice[:id] == @invoice2.id.to_s}#returned
        invoice3 = invoices.find {|invoice| invoice[:id] == @invoice3.id.to_s}#returned
        invoice4 = invoices.find {|invoice| invoice[:id] == @invoice4.id.to_s}#packaged

        expect(invoices).to contain_exactly(invoice1, invoice2, invoice4)
        expect(invoices).to_not include([invoice3])
      end

      it "all records of a merchant's invoices for shipped orders." do
        get "/api/v1/merchants/#{@macho_man.id}/invoices?status=shipped"
        expect(response).to be_successful

        invoices = JSON.parse(response.body, symbolize_names: true)[:data]
        invoice1 = invoices.find {|invoice| invoice[:id] == @invoice1.id.to_s}#shipped
        invoice2 = invoices.find {|invoice| invoice[:id] == @invoice2.id.to_s}#returned
        invoice3 = invoices.find {|invoice| invoice[:id] == @invoice3.id.to_s}#returned
        invoice4 = invoices.find {|invoice| invoice[:id] == @invoice4.id.to_s}#packaged

        expect(invoices).to contain_exactly(invoice1)
        expect(invoices).to_not include([invoice2, invoice3, invoice4])
      end

      it "all records of a merchant's invoices for returned orders." do
        get "/api/v1/merchants/#{@macho_man.id}/invoices?status=returned"
        expect(response).to be_successful
        invoices = JSON.parse(response.body, symbolize_names: true)[:data]
        invoice1 = invoices.find {|invoice| invoice[:id] == @invoice1.id.to_s}#shipped
        invoice2 = invoices.find {|invoice| invoice[:id] == @invoice2.id.to_s}#returned
        invoice3 = invoices.find {|invoice| invoice[:id] == @invoice3.id.to_s}#returned
        invoice4 = invoices.find {|invoice| invoice[:id] == @invoice4.id.to_s}#packaged

        expect(invoices).to contain_exactly(invoice2)
        expect(invoices).to_not include([invoice1, invoice3, invoice4])
      end

      it "all records of a merchant's invoices for packaged orders." do
        get "/api/v1/merchants/#{@macho_man.id}/invoices?status=packaged"
        expect(response).to be_successful
        invoices = JSON.parse(response.body, symbolize_names: true)[:data]
        invoice1 = invoices.find {|invoice| invoice[:id] == @invoice1.id.to_s}#shipped
        invoice2 = invoices.find {|invoice| invoice[:id] == @invoice2.id.to_s}#returned
        invoice3 = invoices.find {|invoice| invoice[:id] == @invoice3.id.to_s}#returned
        invoice4 = invoices.find {|invoice| invoice[:id] == @invoice4.id.to_s}#packaged

        expect(invoices).to contain_exactly(invoice4)
        expect(invoices).to_not include([invoice1, invoice2, invoice3])
      end

      it "returns a 404 error if merchant is not found" do
        get "/api/v1/merchants/0/invoices"
  
        expect(response).to_not be_successful
        expect(response.status).to eq(404) 
  
        data = JSON.parse(response.body, symbolize_names: true)
  
        expect(data[:errors]).to be_a(Array)
        expect(data[:message]).to eq('We could not complete your request, please enter new query.')
        expect(data[:errors]).to eq(["Couldn't find Merchant with 'id'=0"])
      end
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
      expect(data[:id]).to eq(store2.id.to_s)
      expect(data[:attributes][:name]).to eq(store2.name)
    end

    it 'will handle incorrect searches' do
      get "/api/v1/merchants/find?name=1234"
      data = JSON.parse(response.body, symbolize_names: true)

      expect(response).to_not be_successful
      expect(response.status).to eq(404)
      expect(data[:errors]).to be_a(Array)

      expect(data[:message]).to eq("We could not complete your request, please enter new query.")
      expect(data[:errors]).to eq(["Merchant not found"])
    end
  end

  describe 'Index Action' do
    it 'Can sort merchants by age' do
      get "/api/v1/merchants?sorted=age"

      expect(response).to be_successful

      merchants = JSON.parse(response.body, symbolize_names: true)[:data]
      
      expect(merchants.first[:attributes][:name]).to eq(@hot_topic.name)
      expect(merchants.last[:attributes][:name]).to eq(@macho_man.name)
    end

    it 'Can display only merchants with invoice status="returned"' do
      
      get "/api/v1/merchants?status=returned"
      
      expect(response).to be_successful
      
      merchants = JSON.parse(response.body, symbolize_names: true)[:data]
      
      expect(merchants.first[:attributes][:name]).not_to eq([@kozey_group.name])
      expect(merchants.first[:attributes][:name]).to eq(@macho_man.name)
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

  describe 'sad path exception handlers' do
    it 'handles incorrect id parameter for #show' do
      get "/api/v1/merchants/0"
      expect(response).to_not be_successful
      expect(response.status).to eq(404)
      data = JSON.parse(response.body, symbolize_names: true)

      expect(data[:errors]).to be_a(Array)
      expect(data[:message]).to eq('We could not complete your request, please enter new query.')
      expect(data[:errors]).to eq(["Couldn't find Merchant with 'id'=0"])
    end

    it 'handles incorrect id parameter for #patch' do
      patch "/api/v1/merchants/0", params: { merchant: { name: "Mr. Newname" } }

      expect(response).to_not be_successful
      expect(response.status).to eq(404)
      data = JSON.parse(response.body, symbolize_names: true)

      expect(data[:errors]).to be_an(Array)
      expect(data[:message]).to eq('We could not complete your request, please enter new query.')
      expect(data[:errors]).to eq(["Couldn't find Merchant with 'id'=0"])
    end

    it 'handles incorrect id parameter for #delete' do
      delete "/api/v1/merchants/0"

      expect(response).to_not be_successful
      expect(response.status).to eq(404)
      data = JSON.parse(response.body, symbolize_names: true)

      expect(data[:errors]).to be_a(Array)
      expect(data[:message]).to eq('We could not complete your request, please enter new query.')
      expect(data[:errors]).to eq(["Couldn't find Merchant with 'id'=0"])
    end

    it 'handles missing param for #update' do
      id = @kozey_group.id
      original_name = @kozey_group.name
      invalid_params = { name: "" }
      headers = { "CONTENT_TYPE" => "application/json" }
    
      patch "/api/v1/merchants/#{id}", headers: headers, params: JSON.generate({ merchant: invalid_params })
      
      updated_merchant = Merchant.find_by(id: id)
    
      expect(response.status).to eq(422) 
      expect(updated_merchant.name).to eq(original_name)
      data = JSON.parse(response.body)
    end

    it "handles missing param for #create" do
      expect(Merchant.count).to eq(3)
      invalid_merchant_params = { name: "" }

      post "/api/v1/merchants", params: invalid_merchant_params, as: :json
      
      expect(response).to_not be_successful
      expect(response.status).to eq(422)

      data = JSON.parse(response.body, symbolize_names: true)
      expect(data[:errors]).to be_an(Array)
      expect(data[:message]).to eq("Name is required")
      expect(data[:errors]).to eq(["Name is required to create new Merchant"])

      expect(Merchant.count).to eq(3)
    end
  end
end