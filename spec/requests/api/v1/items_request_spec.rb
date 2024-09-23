require 'rails_helper'

RSpec.describe 'Item Endpoints:' do
  before (:each) do
    @kozey_group = Merchant.create!(name: "Kozey Group")

    @item1 = Item.create!(name: "Item One",
      description: "This is item 1.",
      unit_price: 42.91,
      merchant_id: @kozey_group.id
      )
    @item2 = Item.create!(name: "Item Two",
      description: "This is item 2.",
      unit_price: 15.49,
      merchant_id: @kozey_group.id
      )
    @item3 = Item.create!(name: "Item Three",
      description: "This is item 3.",
      unit_price: 100.99,
      merchant_id: @kozey_group.id
      )
    @item4 = Item.create!(name: "Sweater",
      description: "This is a warm, fuzzy sweater.",
      unit_price: 19.99,
      merchant_id: @kozey_group.id
      )
  end

  describe 'HTTP Requests:' do
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

    it 'can get one item' do
      get "/api/v1/items/#{@item2.id}"
      expect(response).to be_successful
      item = JSON.parse(response.body, symbolize_names: true)[:data]
      expect(item[:id]).to eq(@item2.id.to_s)
      expect(item[:attributes][:name]).to eq(@item2.name)
      expect(item[:attributes][:unit_price]).to eq(@item2.unit_price)
    end

    it "can create a item" do
      expect(Item.count).to eq(4)

      new_item_params = {name: "iTem", description: "apples", unit_price: 1299.99, merchant_id: "#{@kozey_group.id}".to_i }

      post "/api/v1/items", params: new_item_params, as: :json
  
      expect(response).to be_successful
      expect(Item.count).to eq(5)
      new_item = Item.last

      expect(new_item.name).to eq(new_item_params[:name])
      expect(new_item.description).to eq(new_item_params[:description])
      expect(new_item.unit_price).to eq(new_item_params[:unit_price])
      expect(new_item.merchant_id).to eq(new_item_params[:merchant_id])

    end

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

    it 'can destroy an item' do
      expect{ delete "/api/v1/items/#{@item1.id}" }.to change(Item, :count).by(-1)
      expect{ Item.find(@item1.id) }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'can return items sorted by price' do
      expected = {
        data: [
          {
            id: @item2.id.to_s,
            type: 'item',
            attributes: {
              name: @item2.name,
              description: @item2.description,
              unit_price: @item2.unit_price,
              merchant_id: @item2.merchant_id
            }
          },
          {
            id: @item4.id.to_s,
            type: 'item',
            attributes: {
              name: @item4.name,
              description: @item4.description,
              unit_price: @item4.unit_price,
              merchant_id: @item4.merchant_id
            }
          },
          {
            id: @item1.id.to_s,
            type: 'item',
            attributes: {
              name: @item1.name,
              description: @item1.description,
              unit_price: @item1.unit_price,
              merchant_id: @item1.merchant_id
            }
          },
            {
              id: @item3.id.to_s,
              type: 'item',
              attributes: {
                name: @item3.name,
                description: @item3.description,
                unit_price: @item3.unit_price,
                merchant_id: @item3.merchant_id
              }
            }
        ]
      }
      
      get "/api/v1/items?sorted=price"
      expect(response).to be_successful

      result = JSON.parse(response.body, symbolize_names: true)[:data]
      
      expect(result).to eq(expected[:data])
    end

    it 'can return a single merchant by an items ID' do
      id = @item1.id
      expected = {
        data: {
            id: @kozey_group.id.to_s,
            type: "merchant",
            attributes: {
                name: @kozey_group.name,
                coupons_count: @kozey_group.coupons.count,
                invoice_coupon_count: @kozey_group.invoices.where.not(coupon_id: nil).count
            }
        }
    }
      get "/api/v1/items/#{id}/merchant"
      
      expect(response).to be_successful

      result = JSON.parse(response.body, symbolize_names: true)[:data]

      expect(result).to eq(expected[:data])
    end
  end

  describe "Filter/Sort Items Index:" do
    it 'can find all items by name' do
      get "/api/v1/items/find_all?name=tEm"
      data = JSON.parse(response.body, symbolize_names: true)[:data]
      
      expect(response).to be_successful
      expect(response.status).to eq(200)
      expect(data.first[:id]).to eq(@item1.id.to_s)
      expect(data.last[:id]).to eq(@item2.id.to_s)
    end

    it 'can returns no errors when a search does not find any items' do
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
      expect(data.last[:id]).to eq(@item3.id.to_s)
    end

    it 'can search by maximum price' do
      get "/api/v1/items/find_all?max_price=30"
      data = JSON.parse(response.body, symbolize_names: true)[:data]
      
      expect(response).to be_successful
      expect(response.status).to eq(200)
      expect(data.first[:id]).to eq(@item2.id.to_s)
      expect(data.last[:id]).to eq(@item4.id.to_s)
    end

    it 'can search for both a minimum and maximum price together' do
      get "/api/v1/items/find_all?max_price=20.99&min_price=17"
      data = JSON.parse(response.body, symbolize_names: true)[:data]
      
      expect(response).to be_successful
      expect(data.first[:id]).to eq(@item4.id.to_s)
      expect(data.last[:id]).to eq(@item4.id.to_s)
    end
  end

  describe 'Sad Path:' do
    it 'handles searches for names and prices together' do
      get "/api/v1/items/find_all?max_price=30&min_price=10&name=sweater"
      
      data = JSON.parse(response.body, symbolize_names: true)
      expect(response).to_not be_successful
      expect(response.status).to eq(400)
    
      expect(data[:errors]).to eq(["Cannot search by both name and price"])
    end

    it 'handles incorrect id parameter for #show' do
      get "/api/v1/items/4000"
      expect(response).to_not be_successful
      expect(response.status).to eq(404)
      data = JSON.parse(response.body, symbolize_names: true)

      expect(data[:errors]).to be_a(Array)
      expect(data[:message]).to eq("We could not complete your request, please enter new query.")
      expect(data[:errors]).to eq(["Couldn't find Item with 'id'=4000"])
    end

    it 'handles incorrect id parameter for #update' do
      patch "/api/v1/items/5000", params: { item: { name: "Mrs. Newname" } }

      expect(response).to_not be_successful
      expect(response.status).to eq(404)
      data = JSON.parse(response.body, symbolize_names: true)
      expect(data[:error]).to eq("We could not complete your request, please enter new query.")
    end

    it 'handles incorrect id parameter for #delete' do
      delete "/api/v1/items/6000"

      expect(response).to_not be_successful
      expect(response.status).to eq(404)
      data = JSON.parse(response.body, symbolize_names: true)

      expect(data[:errors]).to be_a(Array)
      expect(data[:message]).to eq("We could not complete your request, please enter new query.")
      expect(data[:errors]).to eq(["Couldn't find Item with 'id'=6000"])
    end

    it 'handles nonexistant item_id when returning a single item' do
      get "/api/v1/items/0/merchant"

      expect(response).to_not be_successful
      expect(response.status).to eq(404) 

      data = JSON.parse(response.body, symbolize_names: true)

      expect(data[:errors]).to be_an(Array)
      expect(data[:message]).to eq('We could not complete your request, please enter new query.')
      expect(data[:errors]).to eq(["Couldn't find Item with 'id'=0"])
    end

    it "handles missing params when creating a new item" do
      expect(Item.count).to eq(4)
    
      invalid_item_params = { name: "", description: "nothing", unit_price: 1.00, merchant_id: "#{@kozey_group.id}" }
      post "/api/v1/items", params: invalid_item_params, as: :json

      data = JSON.parse(response.body, symbolize_names: true)
      expect(response.status).to eq(422) 
      expect(Item.count).to eq(4)
      expect(data[:errors]).to be_an(Array)
      expect(data[:message]).to eq("All fields must be filled out")
    end
  end
end
