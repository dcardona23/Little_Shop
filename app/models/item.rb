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

  def self.max_filter(scope, params)
    filter = params[:max_price]
    if filter.present?
      scope.where("unit_price <= ?", "#{filter}")
    else
      scope
    end
  end

  def self.min_filter(scope, params)
    filter = params[:min_price]
    if filter.present?
      scope.where("unit_price >= ?", "#{filter}")
    else
      scope
    end
  end

  def self.filter_items(scope, params)
    max_filter(scope, params).then {min_filter(_1, params)}
  end

end