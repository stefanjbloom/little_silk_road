class Invoice < ApplicationRecord
	belongs_to :merchant
	belongs_to :customer
	has_many :transactions
	has_many :invoice_items
	has_many :items, through: :invoice_items

	validates :customer_id, :merchant_id, :status, presence: {message: "is required"}
	validates :customer_id, :merchant_id, numericality: {only_integer: true, message: "valid id required"}
end