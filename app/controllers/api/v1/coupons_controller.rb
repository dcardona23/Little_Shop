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
    coupon = Coupon.new(coupon_params)

    if coupon.save
        render json: CouponSerializer.new(coupon), status: :created
    else
      error = ActiveRecord::RecordInvalid.new(coupon)
      record_invalid(error)
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

  def record_not_found(exception)
    render json: ErrorSerializer.format_error(exception, 404), status: :not_found
  end

  def record_invalid(exception)
    render json: ErrorSerializer.format_error(exception, 400), status: :bad_request
  end

  def record_parameter_missing(exception)
    render json: ErrorSerializer.format_error(exception, 400), status: :bad_request
  end  

  def invalid_parameters(exception)
    render json: ErrorSerializer.format_error(exception, 400), status: :bad_request
  end

end