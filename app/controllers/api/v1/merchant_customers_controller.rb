class Api::V1::MerchantCustomersController < ApplicationController
  
  def index
    merchant = Merchant.find(params[:id]).id
    customers = Customer.joins(:invoices).where("merchan_ig = ?", merchant)
  end
end
