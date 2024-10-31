class Api::V1::MerchantCustomersController < ApplicationController
  
  def index
    merchant = Merchant.find(params[:id]).id
    customers = Customer.joins(:invoices).where("merchant_id = ?", merchant)
    render json: CustomerSerializer.new(customers)
  rescue ActiveRecord::RecordNotFound => error
    render json: {
        errors: [
          {
            status: "404",
            message: error.message
          }
        ]
      }, status: 404 #alternative status: :not_found
  end
end
