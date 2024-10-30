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
    begin
      item_params = item_param
      render json: ItemSerializer.new(Item.create(item_params)), status: :created
    rescue ActionController::BadRequest => error
      render json: error.message, status: :unprocessable_entity
    end
  end

  def destroy
    render json: Item.delete(params[:id]), status: :no_content
  end

 

  private

  def item_param
    begin
      item_params = params.require(:item)
      item_params.require(:name)
      item_params.require(:description)
      item_params.require(:unit_price)
      item_params.require(:merchant_id)
      item_params.permit(:name, :description, :unit_price, :merchant_id)
    rescue ActionController::ParameterMissing => exception
      raise ActionController::BadRequest.new(
        { error: { status: "422", title: exception.message } }.to_json
      )
    end
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