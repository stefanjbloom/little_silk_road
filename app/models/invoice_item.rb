class InvoiceItem < ApplicationRecord
	belongs_to :invoice
	belongs_to :item

	validates :item_id, :invoice_id, :quantity, :unit_price, presence: {message: "is required"}
	validates :item_id, :invoice_id, :quantity, :unit_price, numericality: {message: "must be valid"}

end