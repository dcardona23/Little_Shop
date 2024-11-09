class MerchantIndexSerializer
	include JSONAPI::Serializer
	set_id :id
	set_type :merchant
	attributes :name

	attribute :item_count do |merchant|
		merchant.items.count
	end

  attribute :coupons_count do |merchant|
    merchant.coupons.count
  end

  attribute :invoice_coupon_count do |merchant|
    merchant.invoices.joins(:coupon).count
  end

end