class Api::V1::MerchantsController < ApplicationController

  def index
    merchants = Merchant.sort_by_age(params[:sorted])
                        .status_returned(params[:status])
                        # .count_items()

    render json: MerchantSerializer.new(merchants)                    
  end

  def show
    # merchant = Merchant.find(params[:id])
    # render json: MerchantSerializer.new(merchant)
    begin
      render json: MerchantSerializer.new(Merchant.find(params[:id]))
    rescue ActiveRecord::RecordNotFound => exception
      render json: {
      errors: [
        {
          status: "404",
          title: exception.message
        }
      ]
    }, status: :not_found
    end
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