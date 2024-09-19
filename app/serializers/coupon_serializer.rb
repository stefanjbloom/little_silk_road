class CouponSerializer
  include JSONAPI::Serializer
  attributes :name, :code, :percent_off, :status
end