class Api::V1::MerchantCustomersController < ApplicationController
  
  def index
    merchant = Merchant.find(params[:id])
    customers = merchant.customers.distinct
    render json: CustomerSerializer.new(customers)
  end
end
