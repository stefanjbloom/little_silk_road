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
    coupons = merchant.coupons
    render json: CouponSerializer.new(coupons)
  end

  def create
    merchant = Merchant.find(params[:merchant_id])
    coupon = merchant.coupons.create
    render json: CouponSerializer.new(coupon), status: :created
  end
end