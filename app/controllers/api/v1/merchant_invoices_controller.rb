class Api::V1::MerchantInvoicesController < ApplicationController

  rescue_from ActiveRecord::RecordNotFound, with: :not_found_response

  def index
    merchant = Merchant.find(params[:id])
    invoices = merchant.invoices.distinct
    invoices = invoices.filter_by_status(params[:status])
    render json: InvoiceSerializer.new(invoices)
  end

  def show
    merchant = Merchant.find(params[:merchant_id])
    invoice = merchant.invoices.find(params[:id])
    render json: InvoiceSerializer.new(invoice)
  end
private

  def not_found_response(exception)
    render json: ErrorSerializer.format_error(exception, "404"), status: :not_found
  end
end