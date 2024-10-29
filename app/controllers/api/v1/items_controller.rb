class Api::V1::ItemsController < ApplicationController

  def index
    items = Item.all
    items = sort_items(items)
    options = {meta: {count: (items.count)}}
    render json: ItemSerializer.new(items, options)
  end





  private

  def sort_items(scope)
    case params[:sorted]
    when 'price'
      scope.order(unit_price: :asc)
    else
      scope
    end
  end

end