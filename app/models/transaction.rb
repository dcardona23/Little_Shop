class Transaction < ApplicationRecord
  belongs_to :invoice

  validates_presence_of :credit_card_number, :presence => true
  validates_presence_of :credit_card_expiration_date, :presence => true
  validates_presence_of :result, :presence => true

end