class Api::V1::MerchantsController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :not_found_response

  def index
    merchants = Merchant.sort_by_age(params[:sorted])
                        .status_returned(params[:status])
                        .count_items(params[:count])
    render json: MerchantSerializer.new(merchants, {params:{count: params[:count]}})
  end

  def show
    merchant = Merchant.find(params[:id])
    render json: MerchantSerializer.new(merchant)
  end

  # def create
  #   merchant = Merchant.create(merchant_params)
  #   if merchant.persisted?
  #     render json: MerchantSerializer.new(merchant), status: 201
  #   else
  #     render json: error_response, status: 422
  #   end
  # end
  def create
    puts "Params: #{params.inspect}"
    merchant = Merchant.create(merchant_params)
    if merchant.persisted?
      render json: MerchantSerializer.new(merchant), status: 201
    else
      error_response = {
        message: "Name is required", 
        errors: merchant.errors.full_messages         
      }
      render json: error_response, status: 422
    end
  end

  def update
    merchant = Merchant.find(params[:id])
    if merchant.update(merchant_params)
      render json: MerchantSerializer.new(merchant)
    else
      error_response = { errors: merchant.errors.full_messages }
      error_response = { 
        message: "Name is required",
        errors: merchant.errors.full_messages }
      render json: error_response, status: 422
    end
  end

  def destroy
    merchant = Merchant.find(params[:id])
    merchant.destroy
    head :no_content
  end

  def find
    merchant = Merchant.search(params[:name])
    if merchant
      render json: MerchantSerializer.new(merchant)
    else
      render json: { data: ErrorSerializer.format_error(StandardError.new("Merchant not found"), "404") }, status: :not_found
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