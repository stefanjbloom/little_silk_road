class Customer < ApplicationRecord
    has_many :invoices

    validates :first_name, :last_name, presence: {message: "is required"}
    validates :first_name, :last_name, comparison: {other_than: "", message: "cannot be blank"}
end