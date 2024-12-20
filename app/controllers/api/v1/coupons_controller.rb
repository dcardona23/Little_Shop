class Api::V1::CouponsController < ApplicationController
  rescue_from ActiveRecord::RecordInvalid, with: :record_invalid

  def index
    coupons = Coupon.filter_coupons(Coupon.all, params)
    render json: CouponSerializer.new(coupons)
  end

  def show
    coupon = Coupon.find(params[:id])
    render json: CouponSerializer.new(coupon)
  end

  def create
    coupon = Coupon.new(coupon_params)

    if coupon.save_coupon
        render json: CouponSerializer.new(coupon), status: :created
    else
      render json: { message: "Your query could not be completed", errors: coupon.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def activate
    coupon = Coupon.find(params[:id])

    if coupon.activate(params[:merchant_id])
      render json: CouponSerializer.new(coupon), status: :ok
    else
      error = ActiveRecord::RecordInvalid.new(coupon)
      record_invalid(error)
    end
  end

  def deactivate
    coupon = Coupon.find(params[:id])

    if coupon.deactivate
      render json: CouponSerializer.new(coupon), status: :ok
    else
      error = ActiveRecord::RecordInvalid.new(coupon)
      record_invalid(error)
    end
  end

  private

  def coupon_params
    params.require(:coupon).permit(:name, :code, :percent_off, :dollar_off, :merchant_id, :active)
  end

  def record_invalid(exception)
    render json: ErrorSerializer.format_error(exception, 400), status: :bad_request
  end

end