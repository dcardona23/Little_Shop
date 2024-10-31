require 'rails_helper'

RSpec.describe Merchant do

  before(:each) do
    merchant1 = Merchant.create(name: "Little Shop of Horrors")
    merchant2 = Merchant.create(name: "Large Shop of Wonders")
    merchant3 = Merchant.create(name: "Wizard's Chest")
  end

  describe 'relationships' do
    it {should have_many :invoices}
    it {should have_many :items}
  end

  describe 'validations' do
    it {should validate_presence_of(:name)}
  end

  describe 'class methods' do
    it 'sorts merchants by time created' do
      sorted_by_age = Merchant.sort_by_age
      
      expect(sorted_by_age[0].name).to eq("Little Shop of Horrors")
      expect(sorted_by_age[1].name).to eq("Large Shop of Wonders")
      expect(sorted_by_age[2].name).to eq("Wizard's Chest")
    end

    it 'returns all merchants that have invoices with a specified status' do
      merchant1 = Merchant.create(name: "Little Shop of Horrors")
      merchant2 = Merchant.create(name: "Large Shop of Wonders")

      bob = Customer.create!(first_name: "Bob", last_name: "Tucker")

      invoice1 = Invoice.create!(customer_id: bob.id, merchant_id: merchant1.id, status: "shipped")
      invoice2 = Invoice.create!(customer_id: bob.id, merchant_id: merchant2.id, status: "shipped")
      invoice3 = Invoice.create!(customer_id: bob.id, merchant_id: merchant1.id, status: "shipped")
      invoice4 = Invoice.create!(customer_id: bob.id, merchant_id: merchant1.id, status: "packaged")

      merchants_with_shipped = Merchant.item_status("shipped")
      merchants_with_packaged = Merchant.item_status("packaged")

      expect(merchants_with_shipped.length).to eq(2)
      expect(merchants_with_shipped).to include(merchant1, merchant2)
      expect(merchants_with_packaged.length).to eq(1)
      expect(merchants_with_packaged).to include(merchant1)
    end

    it 'only returns unique merchants that have invoices with a specified status' do
      merchant1 = Merchant.create(name: "Little Shop of Horrors")
      merchant2 = Merchant.create(name: "Large Shop of Wonders")

      bob = Customer.create!(first_name: "Bob", last_name: "Tucker")

      invoice1 = Invoice.create!(customer_id: bob.id, merchant_id: merchant1.id, status: "shipped")
      invoice1 = Invoice.create!(customer_id: bob.id, merchant_id: merchant1.id, status: "shipped")
      invoice1 = Invoice.create!(customer_id: bob.id, merchant_id: merchant1.id, status: "shipped")
      invoice1 = Invoice.create!(customer_id: bob.id, merchant_id: merchant1.id, status: "shipped")

      invoice4 = Invoice.create!(customer_id: bob.id, merchant_id: merchant2.id, status: "packaged")
      invoice4 = Invoice.create!(customer_id: bob.id, merchant_id: merchant2.id, status: "packaged")
      invoice4 = Invoice.create!(customer_id: bob.id, merchant_id: merchant2.id, status: "packaged")
      
      merchants_with_shipped = Merchant.item_status("shipped")
      merchants_with_packaged = Merchant.item_status("packaged")

      expect(merchants_with_shipped.length).to eq(1)
      expect(merchants_with_shipped).to include(merchant1)
      expect(merchants_with_packaged.length).to eq(1)
      expect(merchants_with_packaged).to include(merchant2)
    end

  end
end