class Api::V1::MerchantsController < ApplicationController

  def index
    merchants = Merchant.all
    render json: MerchantSerializer.new(merchants)
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
      render json: {
        errors: [
        {
          status: "404",
          message: "Merchant not found"
        }
      ]}, status: 404
    end
  end

  private

  def merchant_params
    params.require(:merchant).permit(:name)
  end
end