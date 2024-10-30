class Api::V1::MerchantsController < ApplicationController

  def index
    merchants = Merchant.all

    merchants = merchants.sort_by_age if params[:sorted] == "age"

    render json: MerchantIndexSerializer.new(merchants)
  end

  def create
      begin
        merchant = Merchant.create!(merchant_params)
        render json: MerchantIndexSerializer.new(merchant, attributes: {params["item_count"] => merchant.items.count}), status: :created

      rescue ActiveRecord::RecordInvalid => exception
        render json: {
          'message': "your query could not be completed",
          'errors': exception.record.errors.full_messages
      }, status: :bad_request
    end
  end

  def show
    merchant = Merchant.find(params[:id])

    render json: MerchantShowSerializer.new(merchant)
  end

  def destroy
    render json: Merchant.delete(params[:id])
  end

  def merchant_params
    params.require(:merchant).permit(:name)
  end

end