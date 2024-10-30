class Api::V1::MerchantsController < ApplicationController

  def index
    merchants = Merchant.all

    merchants = Merchant.returned_items("returned") if params[:status] == "returned"
    merchants = merchants.sort_by_age if params[:sorted] == "age"
    
    render json: MerchantIndexSerializer.new(merchants)
  end

  def create
      begin
        merchant = Merchant.create!(merchant_params)
        render json: MerchantShowSerializer.new(merchant), status: :created

      rescue ActiveRecord::RecordInvalid => exception
        render json: {
          'message': "your query could not be completed",
          'errors': [exception.message]
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

  def update
    updateMerchant = Merchant.update(params[:id], merchant_params)
    render json: MerchantShowSerializer.new(updateMerchant)
  end

  def merchant_params
    params.require(:merchant).permit(:name)
  end

end