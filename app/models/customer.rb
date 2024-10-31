class Customer < ApplicationRecord
  has_many :invoices

  validates_presence_of :first_name, :presence => true
  validates_presence_of :last_name, :presence => true

end