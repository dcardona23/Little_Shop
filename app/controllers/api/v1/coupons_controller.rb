class Api::V1::CouponsController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from ActiveRecord::RecordInvalid, with: :record_invalid
  rescue_from ArgumentError, with: :invalid_parameters

  def index
    coupons = Coupon.filter_coupons(Coupon.all, params)
    render json: CouponSerializer.new(coupons)
  end

  def show
    coupon = Coupon.find(params[:id])
    render json: CouponSerializer.new(coupon)
  end

  def create
    coupon = Coupon.create!(coupon_params)
    render json: CouponSerializer.new(coupon), status: :created
  end

  def activate
    coupon = Coupon.find(params[:id])

    if coupon.activate(params[:merchant_id])
      render json: { message: "Coupon activated successfully" }, status: :ok
    else
      render json: { error: "Cannot activate this coupon" }, status: :unprocessable_entity
    end
  end

  def deactivate
    coupon = Coupon.find(params[:id])

    if coupon.deactivate
      render json: { message: "Coupon deactivated successfully" }, status: :ok
    else
      render json: { error: "Cannot deactivate this coupon" }, status: :unprocessable_entity
    end
  end

  private

  def coupon_params
    params.require(:coupon).permit(:name, :code, :percent_off, :dollar_off, :merchant_id, :active)
  end

end