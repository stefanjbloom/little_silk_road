class Api::V1::MerchantItemsController < ApplicationController
  
  def index
    merchant = Merchant.find(params[:id])
    items = merchant.items

    if merchant
      render json: MerchantSerializer.new(merchant)
    else
      render json: {
        errors: [
        {
          status: "404",
          message: "Merchant not found"
        }
      ]}, status: 404
    end
  end
end