class Api::V1::ItemsMerchantsController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  def index
    item = Item.find(params[:id])
    merchant = Merchant.find(item.merchant_id)
    render json: MerchantIndexSerializer.new(merchant)
  end

  private

  def record_not_found(exception)
    render json: ErrorSerializer.format_error(exception, 404), status: :not_found
  end
end
