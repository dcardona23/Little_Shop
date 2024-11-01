class Api::V1::MerchantInvoicesController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  def index
    merchant = Merchant.find(params[:id])
    invoices = params[:status] ? merchant.invoices.where(status: params[:status]) : merchant.invoices

    if invoices.present?
      render json: MerchantInvoiceSerializer.new(invoices)
    else
      render json: ErrorSerializer.format_error(StandardError.new("No invoices found with status #{params[:status]}"), 404), status: :not_found
    end
  end

  private

  def record_not_found(exception)
    render json: ErrorSerializer.format_error(exception, 404), status: :not_found
  end
end
