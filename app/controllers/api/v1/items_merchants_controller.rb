class Api::V1::ItemsMerchantsController < ApplicationController

  def index
    item = Item.find(params[:id])
    merchant = Merchant.find(item.merchant_id)
    render json: MerchantSerializer.new(merchant)
  end
end