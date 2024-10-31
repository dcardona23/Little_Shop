class Invoice < ApplicationRecord
  belongs_to :customer
  belongs_to :merchant
  has_many :transactions
  has_many :invoiceItems

  def self.find_by_status(input)
    where(status: input)
  end
end