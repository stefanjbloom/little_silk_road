class Api::V1::ItemsMerchantController < ApplicationController
  
  def index
    begin
      item = Item.find(params[:id])
      merchant = item.merchant
      render json: MerchantSerializer.new(merchant)
    rescue ActiveRecord::RecordNotFound
      render json: {error: "404: Item Not Found"}, status: 404
    end
  end
end
# return the merchant associated with an item
# return a 404 if the item is not found