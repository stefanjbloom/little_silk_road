class InvoiceSerializer
  include JSONAPI::Serializer
  attributes  :status, :merchant_id, :customer_id, :coupon_id
end 