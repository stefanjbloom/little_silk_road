class Api::V1::ItemsController < ApplicationController


  def update
    updated_item = Item.update(params[:id], item_params)
    render json: ItemSerializer.new(updated_item)
  end

  def destroy
    render json: Item.delete(params[:id]), status: 204
  end

  private

  def item_params
    params.require(:item).permit(:name, :description, :unit_price, :merchant_id)
  end
end