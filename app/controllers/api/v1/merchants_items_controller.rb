class Api::V1::MerchantsItemsController < ApplicationController

  def index
    merchant = Merchant.find(params[:id])
    items = Item.where(merchant_id: merchant.id)
    render json: ItemSerializer.new(items)
  end
end