class Api::V1::ItemsController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from ActiveRecord::RecordInvalid, with: :record_invalid
  rescue_from ArgumentError, with: :invalid_parameters
  def index
    items = Item.all
    validate_params
    items = Item.sort_items(items, params)
    items = Item.filter_items(items, params)
    options = { meta: { count: items.count } }
    render json: ItemSerializer.new(items, options)
  end

  def show
    item = Item.find(params[:id])
    render json: ItemSerializer.new(item)
  end
  
  def create
    item = Item.create!(item_params)
    render json: ItemSerializer.new(item), status: :created
  end
  
  def update
    item = Item.find(params[:id])
    item.update!(item_params)
    render json: ItemSerializer.new(item)
  end
  
  def destroy
    render json: Item.delete(params[:id]), status: :no_content
  end

  private

  def item_params
    params.require(:item).permit(:name, :description, :unit_price, :merchant_id)
  end

  def record_not_found(exception)
    render json: ErrorSerializer.format_error(exception, 404), status: :not_found
  end

  def record_invalid(exception)
    render json: ErrorSerializer.format_error(exception, 404), status: :not_found
  end

  def invalid_parameters(exception)
    render json: ErrorSerializer.format_error(exception, 400), status: :bad_request
  end

  def validate_params
    if params[:name].present? && (params[:min_price].present? || params[:max_price].present?)
      raise ArgumentError, "Cannot search for a name and price at the same time"
    elsif params[:min_price].present? && !params[:min_price].to_f.positive?
      raise ArgumentError, "Cannot have a negative number for min_price"
    elsif params[:max_price].present? && params[:max_price].to_f < 0
      raise ArgumentError, "Max price cannot be 0 or lower than 0"
    end
  end
end