class Api::V1::ItemsController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from ActiveRecord::RecordInvalid, with: :record_invalid

  def index
    items = Item.all
    items = sort_items(items)
    options = { meta: { count: items.count } }
    render json: ItemSerializer.new(items, options)
  end

  def show
    item = Item.find(params[:id])
    render json: ItemSerializer.new(item)
  end

  def update
    # binding.pry
    item = Item.find(params[:id])
    item.update!(item_params)
    render json: ItemSerializer.new(item)
  end

  private

  def item_params
    params.require(:item).permit(:name, :description, :unit_price, :merchant_id)
  end

  def sort_items(scope)
    case params[:sorted]
    when 'price'
      scope.order(unit_price: :asc)
    else
      scope
    end
  end

  def record_not_found(exception)
    render json: ErrorSerializer.format_error(exception, 404), status: :not_found
  end

  def record_invalid(exception)
    render json: ErrorSerializer.format_error(exception, 404), status: :not_found
  end
end
