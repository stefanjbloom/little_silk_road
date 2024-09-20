class CouponSerializer
  include JSONAPI::Serializer
  attributes :name, :code, :percent_off, :status
  attribute :usage_count do |coupon, params|
    params[:usage_count] || 0
  end
end