class Api::V1::MerchantsController < ApplicationController

  def index
    merchants = Merchant.all
    render json: MerchantSerializer.new(merchants)
  end

  def create
    merchant = Merchant.create(merchant_params)
    render json: MerchantSerializer.new(merchant), status: 201 if merchant.persisted?
    render json: { errors: merchant.errors.messages }, status: 422 unless merchant.persisted?  
  end

  private
  def merchant_params
    params.require(:merchant).permit(:name)
  end
end