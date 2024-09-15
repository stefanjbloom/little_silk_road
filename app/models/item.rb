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

	def self.search_by_params(param)
		if param[:name] && (param[:min_price] || param[:max_price])
			raise ArgumentError.new("Cannot search by both name and price")
		end

		items = Item.all
		if param[:name]
			items = filter_by_name(items, param[:name])
		end

		if param[:min_price]
			items = filter_by_min(items, param[:min_price])
		end

		if param[:max_price]
			items = filter_by_max(items, param[:max_price])
		end
		items
	end

	def self.filter_by_name(items, name)
		items.where("name ILIKE ?", "%#{name}%").order(:name)
	end

	def self.filter_by_min(items, min_price)
		items.where("unit_price >= #{min_price}").order(:name)
	end

	def self.filter_by_max(items, max_price)
		items.where("unit_price <= #{max_price}").order(:name)
	end
end