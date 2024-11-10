class Coupon < ApplicationRecord
  belongs_to :merchant
  has_many :invoices

  validates :name, :presence => true
  validates :code, :presence => true, uniqueness: true
  
  after_initialize :set_default_inactive, if: :new_record?

  def self.filter_coupons(scope, params)
    scope = scope.where(merchant_id: params[:merchant_id]) if params[:merchant_id]
    scope = scope.where(active: true) if params[:active].present? && params[:active].to_s.downcase == 'true'
    scope = scope.where(active: false) if params[:active].present? && params[:active].to_s.downcase == 'false'

    scope.to_a
  end

  def set_default_inactive
    self.active ||= false
  end

  def activate(merchant_id)
    if active
      errors.add(:base, "Coupon is already active") 
      false
    elsif can_activate? && !active
      update(active: true)
    else
      errors.add(:base, "Merchant cannot have more than 5 active coupons")
      false
    end
  end

  def deactivate
    if active
      invoices_with_coupon = Invoice.where(coupon_id: self.id).exists?

      if !invoices_with_coupon
        update(active: false)
      else
        errors.add(:base, "Coupon cannot be deactivated with pending invoices")
        false
      end
      
    else
      errors.add(:base, "Coupon is already inactive")
      false
    end
  end

  def can_activate?
    !active && Coupon.where(merchant_id: merchant_id, active: true).count < 5
  end

end