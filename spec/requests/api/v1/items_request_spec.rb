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
      unit_price: 15.49,
      merchant_id: @KozeyGroup.id
      )

    @item3 = Item.create!(name: "Item Three",
      description: "This is item 3.",
      unit_price: 100.99,
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

    it 'Can return one item' do
      get "/api/v1/items/#{@item2.id}"
      expect(response).to be_successful
      item = JSON.parse(response.body, symbolize_names: true)[:data]
      expect(item[:id]).to eq(@item2.id.to_s)
      expect(item[:attributes][:name]).to eq(@item2.name)
      expect(item[:attributes][:unit_price]).to eq(@item2.unit_price)
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
  end
end
