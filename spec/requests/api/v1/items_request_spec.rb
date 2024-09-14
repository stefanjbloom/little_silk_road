require 'rails_helper'

RSpec.describe 'Item Endpoints' do
  before (:each) do
    @KozeyGroup = Merchant.create!(name: "Kozey Group")
    @item1 = Item.create!(name: "Item One",
      description: "This is item 1.",
      unit_price: 42.91,
      merchant_id: @KozeyGroup.id
      )
    @item2 = Item.create!(name: "Item Two",
      description: "This is item 2.",
      unit_price: 80.99,
      merchant_id: @KozeyGroup.id
      )
    @item3 = Item.create!(name: "Sweater",
      description: "This is a warm, fuzzy sweater.",
      unit_price: 19.99,
      merchant_id: @KozeyGroup.id
      )
  end

  describe 'HTTP Requests' do
    it 'can update item attributes' do
      id = @item1.id
      previous_name = @item1.name
      item_params = {name: "New Item Name"}
      headers = {"CONTENT_TYPE" => "application/json"}

      patch "/api/v1/items/#{id}", headers: headers, params: JSON.generate({item: item_params})
      updated_item = Item.find_by(id: id)

      expect(response).to be_successful
      expect(updated_item.name).to_not eq(previous_name)
      expect(updated_item.name).to eq("New Item Name")
    end

    it 'can delete an item' do
      expect{ delete "/api/v1/items/#{@item1.id}" }.to change(Item, :count).by(-1)
      expect{ Item.find(@item1.id) }.to raise_error(ActiveRecord::RecordNotFound)
    end
    it 'can get all items' do
      get "/api/v1/items"
      expect(response).to be_successful

      items = JSON.parse(response.body, symbolize_names: true)[:data]

      items.each do |item|

        expect(item).to have_key(:id)
        expect(item[:id]).to be_a(String)

        expect(item).to have_key(:type)
        expect(item[:type]).to eq("item")

        item = item[:attributes]

        expect(item).to have_key(:name)
        expect(item[:name]).to be_a(String)

        expect(item).to have_key(:description)
        expect(item[:description]).to be_a(String)

        expect(item).to have_key(:unit_price)
        expect(item[:unit_price]).to be_a(Float)

        expect(item).to have_key(:merchant_id)
        expect(item[:merchant_id]).to be_a(Integer)
      end
    end
  end

  describe "Find_all Action" do
    it 'can find all items based on search criteria' do
      get "/api/v1/items/find_all?name=tEm"
      data = JSON.parse(response.body, symbolize_names: true)[:data]
      
      expect(response).to be_successful
      expect(response.status).to eq(200)
      expect(data.first[:id]).to eq(@item1.id.to_s)
      expect(data.last[:id]).to eq(@item2.id.to_s)
    end

    it 'returns no errors when a search does not find any items that meet the criteria' do
      get "/api/v1/items/find_all?name=1234"
      data = JSON.parse(response.body, symbolize_names: true)[:data]
   
      expect(response).to be_successful
      expect(response.status).to eq(200)
      expect(data).to eq([])

      get "/api/v1/items/find_all?max_price=10"
      data = JSON.parse(response.body, symbolize_names: true)[:data]
      
      expect(response).to be_successful
      expect(response.status).to eq(200)
      expect(data).to eq([])
    end

    it 'can search by minimum price' do
      get "/api/v1/items/find_all?min_price=30"
      data = JSON.parse(response.body, symbolize_names: true)[:data]
      
      expect(response).to be_successful
      expect(response.status).to eq(200)
      expect(data.first[:id]).to eq(@item1.id.to_s)
      expect(data.last[:id]).to eq(@item2.id.to_s)
    end

    it 'can search by maximum price' do
      get "/api/v1/items/find_all?max_price=30"
      data = JSON.parse(response.body, symbolize_names: true)[:data]

      expect(response).to be_successful
      expect(response.status).to eq(200)
      expect(data.first[:id]).to eq(@item3.id.to_s)
    end

    it 'can search for both a minimum and maximum price together' do
      get "/api/v1/items/find_all?max_price=30&min_price=10"
      data = JSON.parse(response.body, symbolize_names: true)[:data]

      expect(response).to be_successful
      expect(data.first[:id]).to eq(@item3.id.to_s)
      expect(data.last[:id]).to eq(@item3.id.to_s)
    end

    it 'handles searches for names and prices together' do
      get "/api/v1/items/find_all?max_price=30&min_price=10&name=sweater"
      data = JSON.parse(response.body, symbolize_names: true)
      
      expect(response).to_not be_successful
      expect(data[:errors].first[:message]).to eq("Cannot search by both name and price")
    end
  end
end
