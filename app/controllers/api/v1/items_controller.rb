class Api::V1::ItemsController < ApplicationController

  def index
    items = Item.all
    items = sort_items(items)
    options = {meta: {count: (items.count)}}
    render json: ItemSerializer.new(items, options)
  end

  def show
    begin
      item = Item.find(params[:id])
      render json: ItemSerializer.new(item)
    rescue ActiveRecord::RecordNotFound => exception
      render json: {
        errors: [
          {
            status: "404",
            title: exception.message
          }
        ]
      }, status: :not_found
    end
  end
  
  def create
    item = Item.create(item_param)
    render json: ItemSerializer.new(item), status: :created
  end

  def destroy
    render json: Item.destroy(params[:id])
  end


  private

  def item_param
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

end