class InvoiceItem < ApplicationRecord
  belongs_to :item
  belongs_to :invoice

  validates_presence_of :quantity, :presence => true
  validates_presence_of :unit_price, :presence => true

end