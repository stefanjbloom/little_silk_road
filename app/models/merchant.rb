class Merchant < ApplicationRecord
	has_many :items, dependent: :destroy
	has_many :invoices, dependent: :destroy
    has_many :customers, through: :invoices

	validates :name, presence: { message: "Please enter a merchant name" }
	validates :name, uniqueness: { message: "This merchant has already been created" }

    def self.sort_by_age(sorted)
        # require 'pry'; binding.pry
        if sorted == "age"
            order(created_at: :desc)
        else
            all
        end
    end
end