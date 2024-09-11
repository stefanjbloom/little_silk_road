class Merchant < ApplicationRecord
	has_many :items
	has_many :invoices

	validates :name, presence: { message: "is required" }
	validates :name, uniqueness: { message: "needs to be unique" }
end