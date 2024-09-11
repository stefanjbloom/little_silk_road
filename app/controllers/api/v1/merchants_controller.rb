class Api::V1::MerchantsController < ApplicationController

  def index
    merchants = Merchant.all
    render json: MerchantSerializer.new(merchants)
  end

  def update
    updated_merchant = Merchant.update(params[:id], merchant_params)
    render json: MerchantSerializer.new(updated_merchant)
  end

  private

  def merchant_params
    params.require(:merchant).permit(:name)
  end
end