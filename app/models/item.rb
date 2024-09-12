class Item < ApplicationRecord
	belongs_to :merchant
	has_many :invoice_items
	has_many :invoices

	validates :name, :description, :unit_price, :merchant_id {message: "is required"}
	validates :name, :description, :unit_price, comparison: {other_than: "", message: "cannot be blank"}
	validates :unit_price, numericality: {message: "should be a valid price"}
end