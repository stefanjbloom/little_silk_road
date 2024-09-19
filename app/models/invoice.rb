class Invoice < ApplicationRecord
	belongs_to :merchant
	belongs_to :customer
	belongs_to :coupon, optional: true
	has_many :transactions
	has_many :invoice_items
	has_many :items, through: :invoice_items

	validates :customer_id, :merchant_id, :status, presence: {message: "is required"}
	validates :customer_id, :merchant_id, numericality: {only_integer: true, message: "valid id required"}

	def self.filter_by_status(status)
    return all unless status.present?
    where(status: status)
	end
end