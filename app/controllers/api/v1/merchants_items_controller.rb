class Api::V1::MerchantsItemsController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  def index
    merchant = Merchant.find(params[:id])
    items = Item.where(merchant_id: merchant.id)
    options = { meta: { count: items.count } }
    render json: ItemSerializer.new(items, options)
  end

  private

  def record_not_found(exception)
    render json: ErrorSerializer.format_error(exception, 404), status: :not_found
  end
end