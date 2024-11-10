class Invoice < ApplicationRecord
  belongs_to :customer
  belongs_to :merchant
  belongs_to :coupon, optional: true
  has_many :transactions
  has_many :invoice_items
  has_many :items, through: :invoice_items

  validates_presence_of :status, :presence => true
  validate :coupon_merchant_sells_invoice_items

  def self.find_by_status(input)
    where(status: input)
  end

  private

  def coupon_merchant_sells_invoice_items
    return if coupon.nil?

    unless items.exists?(merchant_id: coupon.merchant_id)
      errors.add(:coupon, "Merchant does not sell an item on this invoice to which the coupon can be applied")
    end
  end
end