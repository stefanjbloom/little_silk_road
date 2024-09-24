class Api::V1::CouponsController < ApplicationController

  def show 
    merchant = Merchant.find(params[:merchant_id])
    coupon = merchant.coupons.find(params[:id])

    used_coupon_count = coupon.invoices.count

    render json: CouponSerializer.new(coupon, { params: { usage_count: used_coupon_count } })
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Coupon not found" }, status: :not_found
  end

  def index
    merchant = Merchant.find(params[:merchant_id])
    coupons = merchant.coupons.sort_by_status(params[:sorted])
    render json: CouponSerializer.new(coupons)
  end

  def create
    merchant = Merchant.find(params[:merchant_id])
    coupon = Coupon.create_a_coupon(merchant, coupon_params)
    coupon.is_a?(Coupon) ? render(json: CouponSerializer.new(coupon), status: :created) : render(json: { errors: coupon[:errors] }, status: :unprocessable_entity)  
  end

  def update
    merchant = Merchant.find(params[:merchant_id])
    coupon = Coupon.find(params[:id])
    updated_coupon = Coupon.change_status(merchant, coupon)

    if updated_coupon[:errors]
      render json: {error: updated_coupon[:errors]}, status: 422
    else
      render json: {message: "Coupon Status Changed"}, status: 200
    end
  end

  private
  def coupon_params
    params.require(:coupon).permit(:name, :code, :percent_off, :status)
  end
end