class Api::V1::CouponsController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from ActiveRecord::RecordInvalid, with: :record_invalid
  rescue_from ArgumentError, with: :invalid_parameters

  def index
    # binding.pry
    coupons = Coupon.filter_coupons(Coupon.all, params)
    render json: CouponSerializer.new(coupons)
  end

  def show
    
  end

end