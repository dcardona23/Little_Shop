class Coupon < ApplicationRecord
  belongs_to :merchant
  has_one :invoice

  validates :name, :presence => true

  def self.filter_coupons(scope, params)
    scope = scope.where(merchant_id: params[:merchant_id]) if params[:merchant_id]
  end

  def set_default_active
    self.active = true if active.nil?
  end

  def activate(coupon)
    if can_activate? 
      update(active: true)
    else
      errors.add(:base, "Merchant cannot have more than 5 active coupons")
      false
    end
  end

  def deactivate
    update(active: false)
  end

  def can_activate?
    !active && Coupon.where(merchant_id: merchant_id, active: true).count < 5
  end

end