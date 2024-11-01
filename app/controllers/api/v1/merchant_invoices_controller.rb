class Api::V1::MerchantInvoicesController < ApplicationController

	def index
		begin
			merchant = Merchant.find(params[:id])
			invoices = merchant.invoices.find_by_status(params[:status]) if (params[:status])
			invoices = merchant.invoices if (!params[:status])

			if invoices.empty? 
				render json: {
					'message': "your query could not be completed",
					'errors': [
						"no invoices found with status #{params[:status]}"
					]
				}, status: :not_found
				return 
			end
	
			render json: MerchantInvoiceSerializer.new(invoices)
	
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