class Api::V1::MerchantCustomersController < ApplicationController

  def index
    merchant = Merchant.find(params[:id])
    customers = merchant.customers
    render json: CustomerSerializer.new(customers)
    # require 'pry'; binding.pry
  end

end
