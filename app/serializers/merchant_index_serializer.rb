class MerchantIndexSerializer
	include JSONAPI::Serializer
	set_id :id
	set_type :merchant
	attributes :name

	attribute :item_count do |merchant|
		merchant.items.count
	end
end