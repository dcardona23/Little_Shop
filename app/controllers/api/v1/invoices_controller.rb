class Api::V1::InvoicesController < ApplicationController

	def index
		merchant = Merchant.find_by(id: params[:id])
		merchant_id = merchant.id

		invoices = Invoice.where(merchant_id: merchant_id).find_by_status(params[:status])

		render json: InvoiceSerializer.new(invoices)
	end
end

#when get request is made for a merchant id, it returns all invoices for that merchant