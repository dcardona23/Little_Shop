class Coupon < ApplicationRecord
  belongs_to :merchant
  has_many :invoices

  validates :code, :presence => true, uniqueness: { message: "has already been taken" }
  validate :dollar_off_or_percent_off_present
  validate :only_one_discount_present
  attribute :usage_count, :integer, default: 0
  
  after_initialize :set_default_inactive, if: :new_record?

 
  def self.filter_coupons(scope, params)
    scope = scope.where(merchant_id: params[:merchant_id]) if params[:merchant_id]
    scope = scope.where(active: true) if params[:active].present? && params[:active].to_s.downcase == 'true'
    scope = scope.where(active: false) if params[:active].present? && params[:active].to_s.downcase == 'false'

    scope.to_a
  end

  def calculate_usage_count
    increment!(:usage_count)
  end

  def dollar_off_or_percent_off_present
    if dollar_off.nil? && percent_off.nil?
      errors.add(:base, "Either dollar_off or percent_off must be present")
    end
  end

  def only_one_discount_present
    if dollar_off.present? && percent_off.present?
      errors.add(:base, "Cannot have both dollar_off and percent_off")
    end
  end

  def save_coupon
    if Coupon.exists?(code: code)
      errors.add(:code, "has already been used")
    end

    if Coupon.where(merchant_id: merchant_id, active: true).count >= 5
      errors.add(:base, "Merchant cannot have more than 5 active coupons") 
      false
    end
    
    return false if errors.any? || !valid?
      save
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
      invoices_with_coupon = Invoice.where(coupon_id: self.id, status: "packaged").exists?

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

private

  def set_default_inactive
    self.active ||= false
  end
end