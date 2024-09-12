class Item < ApplicationRecord
	belongs_to :merchant
	has_many :invoice_items
	has_many :invoices
	has_many :invoices, through: :invoice_items

	validates :name, :description, :unit_price, :merchant_id, presence: { message: "is required" }
	validates :unit_price, numericality: { greater_than_or_equal_to: 0, message: "should be a valid price" }

	def self.order_by(sorted) 
		if sorted == "price"
			order(unit_price: :asc)
		else
			all
		end
	end
end