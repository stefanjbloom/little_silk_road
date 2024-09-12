class Merchant < ApplicationRecord
	has_many :items, dependent: :destroy
	has_many :invoices

	validates :name, presence: { message: "Please enter a merchant name" }
	validates :name, uniqueness: { message: "This merchant has already been created" }
end