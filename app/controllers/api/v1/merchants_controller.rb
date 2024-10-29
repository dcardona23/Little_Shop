class Api::V1::MerchantsController < ApplicationController

  def show
    merchant = Merchant.find(params[:id])
    render json: MerchantSerializer.format_merchant(merchant)
  end
end