class Api::V1::InvoicesController < ApplicationController

	def index
		begin
			merchant = Merchant.find(params[:id])
			invoices = Invoice.where(merchant_id: merchant.id).find_by_status(params[:status])

			if invoices.empty? || !merchant.id
				render json: {
					'message': "your query could not be completed",
					'errors': [
						"no invoices found with the specified status"
					]
				}, status: :not_found
				return 
			end

			render json: InvoiceSerializer.new(invoices)

		rescue ActiveRecord::RecordNotFound
			render json: {
					'message': "your query could not be completed",
					'errors': [
						"merchant not found"
					]
				}, status: :not_found
		end
	end
end