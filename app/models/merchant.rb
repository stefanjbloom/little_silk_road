class Merchant < ApplicationRecord
	has_many :items, dependent: :destroy
	has_many :invoices, dependent: :destroy
  has_many :customers, through: :invoices
	has_many :invoice_items, through: :invoices
	has_many :coupons

	validates :name, presence: { message: "is required to create new Merchant" }
	validates :name, uniqueness: { message: "This merchant has already been created" }
	

	def self.sort_by_age(sorted)
		if sorted == "age"
			order(created_at: :desc)
		else
			all
		end
	end

	def self.status_returned(status)
		if status == "returned"
			joins(:items, :invoices).where(invoices: {status: 'returned'}).distinct
		else
			all
		end
	end
	
	def self.count_items(count)
		if count == "true"
			joins(:items).select('merchants.*, COUNT(items.id) AS item_count')
			.group('merchants.id').order(:id)
		else
			all
		end
	end

	def self.search(param)
		self.where("name ILIKE ?", "%#{param}%").order(:name).first
	end
end