class Merchant < ApplicationRecord
  validates :name, :presence => true
  has_many :invoices
  has_many :items, dependent: :destroy

  def self.sort_by_age
    order('created_at asc')
  end

  def self.item_status(status)
    joins(:invoices).where(invoices: { status: status }).distinct
  end

  # def self.find_by_name(scope, input)
  #   where("name ILIKE ?", "%#{input}%").order(:name).first
  # end

  def self.filter_merchants(scope, params)
    scope = scope.where("name ILIKE ?", "%#{params[:name]}%").order(:name).first if (params[:name])
    scope = scope.item_status(params[:status]) if params[:status]
    scope = scope.sort_by_age if params[:sorted] == "age"
    scope 
  end
end