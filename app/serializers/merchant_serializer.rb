class MerchantSerializer
    include JSONAPI::Serializer
    set_id :id
    attributes :name

    attribute :item_count do |merchant|
        merchant.items.count
    end
end