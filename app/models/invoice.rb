class Invoice < ApplicationRecord
	belongs_to :merchant
	belongs_to :customer
	has_many :transactions
	has_many :invoice_items
	has_many :items, through: :invoice_items

	validates :status, :customer_id, :merchant_id, presence: { message: "is required" }

	def self.filter_by_status(status)
    return all unless status.present?
    where(status: status)
	end
end