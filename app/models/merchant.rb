class Merchant < ApplicationRecord
  has_many :invoices
  has_many :items

  def self.sort_by_age
    order('created_at asc')
  end
end