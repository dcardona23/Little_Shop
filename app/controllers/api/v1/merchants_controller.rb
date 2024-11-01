class Api::V1::MerchantsController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from ActiveRecord::RecordInvalid, with: :record_invalid
  rescue_from ActionController::ParameterMissing, with: :record_parameter_missing

  def index
    merchants = Merchant.all

    merchants = merchants.item_status(params[:status]) if params[:status]
    merchants = merchants.sort_by_age if params[:sorted] == "age"
    
    render json: MerchantIndexSerializer.new(merchants)
  end

  def fetch_by_name
    merchant = Merchant.find_by_name(params[:name])

    if merchant 
      render json: MerchantShowSerializer.new(merchant)
    else
      render json: { data: {} }, status: :ok
    end
  end

  def show
    merchant = Merchant.find(params[:id])
    render json: MerchantShowSerializer.new(merchant)
  end

  def create
    merchant = Merchant.create!(merchant_params)
    render json: MerchantShowSerializer.new(merchant), status: :created
  end
  
  def update
    updateMerchant = Merchant.update!(params[:id], merchant_params)
    render json: MerchantShowSerializer.new(updateMerchant)
  end

  def destroy
    render json: Merchant.delete(params[:id])
  end

  private

  def merchant_params
    params.require(:merchant).permit(:name)
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
end