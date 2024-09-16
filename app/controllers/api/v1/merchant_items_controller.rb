class Api::V1::MerchantItemsController < ApplicationController
  
  
  def index
    merchant = Merchant.find(params[:id])
    items = merchant.items

    render json: ItemSerializer.new(items)
  end

  private

  def not_found_response(exception)
    render json: ErrorSerializer.format_error(exception, "404"), status: :not_found
  end
end