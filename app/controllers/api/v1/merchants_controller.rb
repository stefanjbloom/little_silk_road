class Api::V1::MerchantsController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :not_found_response

  def index
    merchants = Merchant.sort_by_age(params[:sorted])
                        .status_returned(params[:status])
                        .count_items(params[:count])

    render json: MerchantSerializer.new(merchants, {params:{count: params[:count]}})
    # Pass the params to the render json serializer to include item_count attribute or not.
  end

  def show
    merchant = Merchant.find(params[:id])
    render json: MerchantSerializer.new(merchant)
  end

  def create
    merchant = Merchant.create(merchant_params)
    render json: MerchantSerializer.new(merchant), status: 201 if merchant.persisted?
    render json: { errors: merchant.errors.messages }, status: 422 unless merchant.persisted?  
  end

  def update
    updated_merchant = Merchant.update(params[:id], merchant_params)
    render json: MerchantSerializer.new(updated_merchant)
  end

  def destroy
    merchant = Merchant.find(params[:id])
    merchant.destroy  # This will trigger dependent: :destroy and delete associated items
    head :no_content  # Returns a 204 No Content response
  end

  def find
    merchant = Merchant.search(params[:name])
     if merchant
      render json: MerchantSerializer.new(merchant)
    else
      render json: ErrorSerializer.format_error(StandardError.new("Merchant not found"), "404"), status: :not_found
    end
  end

  private

  def merchant_params
    params.require(:merchant).permit(:name)
  end

  def not_found_response(exception)
    render json: ErrorSerializer.format_error(exception, "404"), status: :not_found
  end
end