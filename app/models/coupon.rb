class Coupon < ApplicationRecord
  belongs_to :merchant
  has_many :invoices

  validates :name, :code, :percent_off, :status, presence: { message: "is required to create new Coupon"}
  validates :name, :code, :percent_off, comparison: {other_than: "", message: "cannot be blank"}
  validates :code, uniqueness: { message: "coupon code must be unique"}
  validates :percent_off, numericality: { greater_than_or_equal_to: 10, only_integer: true, message: "should be a valid price" }
  validates :status, inclusion: { in: ["activated", "deactivated"] }
end