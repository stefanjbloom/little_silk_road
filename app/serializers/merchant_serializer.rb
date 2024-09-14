class MerchantSerializer
  include JSONAPI::Serializer
  attributes :name
  attribute :item_count, if: Proc.new { |merchant, params| params[:count] == "true" } do |merchant|
    merchant.item_count
    # The Proc is an Object that encapsulates a line of code.
    # Its used to conditionally include item_count in an attribute IF query param ?count=true == "true".
    # IF there is no query param ?count=true then item_count wont be included in JSON response
    # Then it dynamically includes item_count in the merchant attribute. The param is provided in the .
  end
end