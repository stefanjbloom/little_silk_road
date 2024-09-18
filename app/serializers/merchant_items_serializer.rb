class MerchantItemsSerializer
  include JSONAPI::Serializer

  set_type :merchant
  attributes :name

  has_many :items, serializer: ItemSerializer
end