class Api::V1::MerchantsController < ApplicationController

  def index
    merchants = Merchant.all

    merchants = merchants.item_status(params[:status]) if params[:status]
    merchants = merchants.sort_by_age if params[:sorted] == "age"
    
    render json: MerchantIndexSerializer.new(merchants)
  end

  def fetch_by_name
    merchant = Merchant.find_by_name(params[:name])

    if merchant 
      render json: MerchantShowSerializer.new(merchant)
    else
      render json: { data: {} }, status: :ok
    end
  end

  def create
    begin
      merchant = Merchant.create!(merchant_params)
      render json: MerchantShowSerializer.new(merchant), status: :created

    rescue ActiveRecord::RecordInvalid => exception
      render json: {
        'message': "your query could not be completed",
        'errors': [exception.message]
    }, status: 422
    end
  end

  def show
    merchant = Merchant.find_by(id: params[:id]) if params[:id]

    if merchant
    render json: MerchantShowSerializer.new(merchant)
    else
      error_message = "Merchant not found"
      render json: ErrorSerializer.format_error(StandardError.new(error_message), "404"), status: :not_found
    end
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