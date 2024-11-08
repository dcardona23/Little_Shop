class Coupon < ApplicationRecord
  belongs_to :merchant
  has_one :invoice

  def self.filter_coupons(scope, params)
    scope = scope.where(merchant_id: params[:merchant_id]) if params[:merchant_id]
  end

end