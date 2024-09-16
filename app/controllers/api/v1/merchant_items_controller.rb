class Api::V1::MerchantItemsController < ApplicationController

  rescue_from ActiveRecord::RecordNotFound, with: :not_found_response

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

# class Api::V1::MerchantItemsController < ApplicationController
  
#   def index
#     merchant = Merchant.find(params[:id])
#     items = merchant.items

#     if merchant
#       items = merchant.items
#       render json: MerchantItemsSerializer.new(merchant, include: [:items])
#     else
#       render json: ErrorSerializer.format_error(StandardError.new("Merchant not found"), "404"), status: :not_found
#     end
#   end

#   private

#   def merchant_params
#     params.require(:merchant).permit(:name)
#   end

#   def item_params
#     params.require(:item).permit(:name, :description, :unit_price, :merchant_id)
#   end

#   def not_found_response(exception)
#     render json: ErrorSerializer.format_error(exception, "404"), status: :not_found
#   end
# end