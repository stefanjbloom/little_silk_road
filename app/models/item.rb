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
		all_items = Item.all
		if param[:name]
			results = filter_by_name(all_items, param[:name])
		end
		results
	end

	def self.filter_by_name(items, name)
		items.where("name ILIKE ?", "%#{name}%").order(:name)
	end

	# def self.filter_by_min(posters, min_price)
	# 		posters.where("price >= #{min_price}")
	# end

	# def self.filter_by_max(posters, max_price)
	# 		posters.where("price <= #{max_price}")
	# end
end