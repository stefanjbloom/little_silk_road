require 'rails_helper'

RSpec.describe 'Item Endpoints' do
  before (:each) do
    @KozeyGroup = Merchant.create!(name: "Kozey Group")
    @item1 = Item.create!(name: "Item One",
      description: "This is item 1.",
      unit_price: 42.91,
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
end
