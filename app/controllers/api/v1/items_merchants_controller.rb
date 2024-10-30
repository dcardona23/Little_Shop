class Api::V1::ItemsMerchantsController < ApplicationController

  def index
    item = Item.find(params[:id])
    merchant = Merchant.find(item.merchant_id)
    render json: MerchantIndexSerializer.new(merchant)
  end
end