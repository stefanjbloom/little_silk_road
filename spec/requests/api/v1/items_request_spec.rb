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
  end
end
# These “index” endpoints for items and merchants should:

# render a JSON representation of all records of the requested resource
# always return an array of data, even if one or zero resources are found
# NOT include dependent data of the resource (e.g., if you’re fetching merchants, do not send any data about merchant’s items or invoices)
# follow this pattern: GET /api/v1/

# For “Fetch all” endpoints that have a condition (i.e. sorted, filtered, etc.), the following parameters should be added to the request to indicate what type of condition should be included in the response:

# ?sorted=price on the items index to sort items by price, cheapest first

# Example JSON response for the Item resource:

# {
#   "data": {
#     "id": "16",
#     "type": "item",
#     "attributes": {
#       "name": "Widget",
#       "description": "High quality widget",
#       "unit_price": 100.99,
#       "merchant_id": 14
#     }
#   }
# }