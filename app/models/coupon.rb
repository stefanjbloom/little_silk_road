class Coupon < ApplicationRecord
  belongs_to :merchant
  has_many :invoices

  scope :active, -> { where(status: "activated") }
  # this creates active method thatexecutes a query like SELECT * FROM coupons WHERE status = "activated"

  validates :name, :code, :percent_off, :status, presence: { message: "is required to create new Coupon"}
  validates :name, :code, :percent_off, comparison: {other_than: "", message: "cannot be blank"}
  validates :code, uniqueness: { message: "coupon code must be unique"}
  validates :percent_off, numericality: { greater_than_or_equal_to: 10, only_integer: true, message: "should be a valid integer" }
  validates :status, inclusion: { in: ["activated", "deactivated"] }
  validate :max_coupons_per_merchant

  def self.create_a_coupon(merchant, coupon_params)
    return {errors: "Merchant can only have 5 active coupons"} if merchant.coupons.active.count >= 5
    return {errors: "Coupon code must be unique"} if merchant.coupons.exists?(code: coupon_params[:code])
    merchant.coupons.create(coupon_params)
  end

  def self.change_status(merchant, coupon)
    if coupon.invoices.where(status: "pending").exists?
      return {errors: "Cannot deactivate coupon if invoice is pending"}
    end

    if coupon.status == "activated"
      coupon.update(status: "deactivated")
    elsif coupon.status == "deactivated"
      coupon.update(status: "activated")
    end
    coupon
  end

  def self.sort_by_status(sorted)
    if sorted == "active"
      where(status: "activated").order(status: :asc)
    elsif sorted == "inactive"
      where(status: "deactivated").order(status: :asc)
    else
      all
    end
  end
  private
# Sad Path Business Logic
  def max_coupons_per_merchant
    if merchant && merchant.coupons.active.count >= 5 && status == "activated"
      errors.add(:merchant, "can only have 5 active coupons at a time")
    end
  end
end