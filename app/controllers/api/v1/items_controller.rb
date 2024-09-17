class Api::V1::ItemsController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :not_found_response

  def index
    items = Item.order_by(params[:sorted])
    render json: ItemSerializer.new(items)
  end

  def show
    item = Item.find(params[:id])
    render json: ItemSerializer.new(item)
  end

  def update
    updated_item = Item.update(params[:id], item_params)
    render json: ItemSerializer.new(updated_item)
    # item = Item.find(params[:id])
    # if item.update(item_params)
    #   render json: ItemSerializer.new(item), status: :ok
    # end
  end

  def destroy
    item = Item.find(params[:id])
    item.destroy
    head :no_content
  end

  def find_all
    begin
      items = Item.search_by_params(find_all_params)
      render json: ItemSerializer.new(items)
    rescue ArgumentError => exception
      render json: ErrorSerializer.format_error(exception, "400"), status: :bad_request
    end
  end

  private

  def item_params
    params.require(:item).permit(:name, :description, :unit_price, :merchant_id)
  end

  def find_all_params
    params.permit(:name, :min_price, :max_price)
  end

  def not_found_response(exception)
    render json: ErrorSerializer.format_error(exception, "404"), status: :not_found
  end
end
