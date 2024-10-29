class Api::V1::ItemsController < ApplicationController

  def index
    items = Item.all
    items = sort_items(items)
    # options = {meta: {count: (items.count)}}
    render json: items
    # render json: ItemSerializer.new(items) #, options)
  end





  private

  def sort_items(scope)
    order = params[:sorted]
    if order.present? && order.presence_in(%[price])
      scope.order(unit_price: order)
    end
  end

end