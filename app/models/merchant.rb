class Merchant < ApplicationRecord
  validates :name, :presence => true
  has_many :invoices
  has_many :items, dependent: :destroy

  def self.sort_by_age
    order('created_at asc')
  end
end