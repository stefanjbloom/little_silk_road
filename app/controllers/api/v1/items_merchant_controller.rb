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
