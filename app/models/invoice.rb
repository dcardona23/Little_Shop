class Invoice < ApplicationRecord
  belongs_to :customer
  belongs_to :merchant
  belongs_to :coupon, optional: true
  has_many :transactions
  has_many :invoice_items
  has_many :items, through: :invoice_items

  validates_presence_of :status, :presence => true
  validate :coupon_merchant_sells_invoice_items
  validate :one_coupon_per_invoice

  after_save :increment_coupon_usage, if: :saved_change_to_coupon_id?

  def self.find_by_status(input)
    where(status: input)
  end

  def invoice_subtotal
    invoice_items.sum { |invoice_item| invoice_item.quantity * invoice_item.unit_price }
  end

  def discount_total
    return 0 unless coupon

    if coupon.percent_off
      invoice_subtotal * (coupon.percent_off.to_f / 100)
    else coupon.dollar_off
      [coupon.dollar_off, invoice_subtotal].min
    end
  end

  def total_invoice_cost
    [invoice_subtotal - discount_total, 0].max
  end

  private

  def coupon_merchant_sells_invoice_items
    return if coupon.nil?

    unless items.exists?(merchant_id: coupon.merchant_id)
      errors.add(:coupon, "Merchant does not sell an item on this invoice to which the coupon can be applied")
    end
  end

  def one_coupon_per_invoice
    errors.add(:coupon, "Only one coupon can be applied per invoice") if
      coupon_id_changed? && coupon_id_was.present?
  end

  def increment_coupon_usage
    coupon.calculate_usage_count if coupon 
  end

end