class Api::V1::ItemsController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from ActiveRecord::RecordInvalid, with: :record_invalid

  def index
    items = Item.all
    items = Item.sort_items(items, params)
    options = { meta: { count: items.count } }
    render json: ItemSerializer.new(items, options)
  end

  def fetch_by_name
    items = Item.find_by_name(params[:name])

    if items 
      render json: ItemSerializer.new(items)
    else
      render json: { data: {} }, status: :ok
    end
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
end
