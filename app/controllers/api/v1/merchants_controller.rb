class Api::V1::MerchantsController < ApplicationController

  def index
    merchants = Merchant.all
    render json: MerchantSerializer.new(merchants)
  end

  def create
      begin
        merchant = Merchant.create!(merchant_params)
        render json: MerchantSerializer.new(merchant), status: :created
      rescue ActiveRecord::RecordInvalid => exception
        render json: {
          'message': "your query could not be completed",
          'errors': exception.record.errors.full_messages
      }, status: :bad_request
    end
  end

  def show
    merchant = Merchant.find(params[:id])
    render json: MerchantSerializer.new(merchant)
  end

  def destroy
    render json: Merchant.delete(params[:id])
  end

  def merchant_params
    params.require(:merchant).permit(:name)
  end

end