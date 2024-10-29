class InvoiceSerializer
    include JSONAPI::Serializer
    set_id :id
    attributes :customer_id, :merchant_id, :status
end