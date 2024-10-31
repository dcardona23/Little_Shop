class MerchantShowSerializer
	include JSONAPI::Serializer
	set_id :id
	set_type :merchant
	attributes :name
end