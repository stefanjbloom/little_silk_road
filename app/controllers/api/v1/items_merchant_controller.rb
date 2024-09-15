class Api::V1::ItemsMerchantController < ApplicationController
  
  def index
    item = Item.find(params[:id])
    merchant = item.merchant
    render json: MerchantSerializer.new(merchant)
  end
end
# return the merchant associated with an item
# return a 404 if the item is not found