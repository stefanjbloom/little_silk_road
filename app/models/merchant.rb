class Merchant < ApplicationRecord
	has_many :items, dependent: :destroy
	has_many :invoices
end