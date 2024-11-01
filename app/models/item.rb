class Item < ApplicationRecord
  belongs_to :merchant
  has_many :invoiceItems

  validates_presence_of :name, :presence => true
  validates_presence_of :description, :presence => true
  validates_presence_of :unit_price, :presence => true

  def self.sort_items(scope, params)
    if params[:sorted].present? && params[:sorted] == 'price'
      scope.order(unit_price: :asc)
    else
      scope
    end
  end
end