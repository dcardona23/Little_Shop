class Api::V1::MerchantsController < ApplicationController

  def index
    merchants = Merchant.all

    merchants = merchants.sort_by_age if params[:sorted] == "age"

    render json: MerchantSerializer.new(merchants)
  end

  def show
    merchant = Merchant.find(params[:id])
    render json: MerchantSerializer.new(merchant)
  end

  def destroy
    render json: Merchant.delete(params[:id])
  end
end