class CustomerSerializer
    include JSONAPI::Serializer
    set_id :id
    attributes :first_name, :last_name
end