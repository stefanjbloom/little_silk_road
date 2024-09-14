class Api::V1::ItemsController < ApplicationController

  def index
    items = Item.order_by(params[:sorted])
    render json: ItemSerializer.new(items)
  end

  def update
    updated_item = Item.update(params[:id], item_params)
    render json: ItemSerializer.new(updated_item)
  end

  def destroy
    render json: Item.delete(params[:id]), status: 204
  end

  def find_all
    begin
      items = Item.search_by_params(find_all_params)
      render json: ItemSerializer.new(items)
    rescue StandardError => exception
      # require 'pry'; binding.pry
      render json: {
        errors: [
        {
          status: "400",
          message: exception.message
        }
      ]}, status: :bad_request
    end
  end

  private

  def item_params
    params.require(:item).permit(:name, :description, :unit_price, :merchant_id)
  end

  def find_all_params
    params.permit(:name, :min_price, :max_price)
  end
end
