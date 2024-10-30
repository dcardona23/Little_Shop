class Api::V1::MerchantCustomersController < ApplicationController
  
  def index
    merchant = Merchant.find(params[:id]).id
    customers = Customer.joins(:invoices).where("merchant_id = ?", merchant)
    render json: CustomerSerializer.new(customers) 
  end
end
