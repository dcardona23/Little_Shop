class Api::V1::MerchantsItemsController < ApplicationController

  def index
    begin
      merchant = Merchant.find(params[:id])
      items = Item.where(merchant_id: merchant.id)
      options = {meta: {count: (items.count)}}
      render json: ItemSerializer.new(items, options)
    rescue ActiveRecord::RecordNotFound => exception
      render json: {
        errors: [
          {
            status: "404",
            title: exception.message
          }
        ]
      }, status: :not_found
    end
  end
end