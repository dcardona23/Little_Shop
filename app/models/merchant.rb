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

  def self.find_by_name(input)
    where("name ILIKE ?", "%#{input}%").order(:name).first
  end
end