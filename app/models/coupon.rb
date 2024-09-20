class Coupon < ApplicationRecord
  belongs_to :merchant
  has_many :invoices

  scope :active, -> { where(status: "activated") }

  validates :name, :code, :percent_off, :status, presence: { message: "is required to create new Coupon"}
  validates :name, :code, :percent_off, comparison: {other_than: "", message: "cannot be blank"}
  validates :code, uniqueness: { message: "coupon code must be unique"}
  validates :percent_off, numericality: { greater_than_or_equal_to: 10, only_integer: true, message: "should be a valid price" }
  validates :status, inclusion: { in: ["activated", "deactivated"] }
  # validates :max_coupons_per_merchant

  private

  def max_coupons_per_merchant
    if merchant && merchant.coupons.active.count >= 5 && status == "activated"
      errors.add(:merchant, "can only have 5 active coupons at a time")
    end
  end
end