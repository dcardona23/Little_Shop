class ItemSerializer
  include JSONAPI::Serializer
  set_id :id
  attributes :name, :description, :unit_price, :merchant_id

  def self.record_hash(record, fieldset, includes_list, params)
    hash = super
    hash[:id] = record.id.to_i
    hash
  end
end