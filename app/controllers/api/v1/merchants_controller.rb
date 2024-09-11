class Api::V1::MerchantsController < ApplicationController

  def index
    merchants = Merchant.all
    render json: MerchantSerializer.new(merchants)
  end

  def create
    options = {}
    merchant = Merchant.create(merchant_params)
    render json: MerchantSerializer.new(merchant), status: 201
  end

  private
  def merchant_params
    params.require(:merchant).permit(:name)
  end
end