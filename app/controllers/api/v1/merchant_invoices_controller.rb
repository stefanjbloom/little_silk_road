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

  def create
    merchant = Merchant.find(params[:merchant_id])
    invoice = Invoice.create_an_invoice(merchant, invoice_params)
    invoice.is_a?(Invoice) ? render(json: InvoiceSerializer.new(invoice), status: :created) : render(json: { errors: invoice[:errors] }, status: :bad_request)  
  end

private

  def invoice_params
    params.require(:invoice).permit(:customer_id, :merchant_id, :coupon_id, :status)
  end

  def not_found_response(exception)
    render json: ErrorSerializer.format_error(exception, "404"), status: :not_found
  end
end