require 'rails_helper'

RSpec.describe Invoice do

  describe 'relationships' do
    it {should belong_to :customer}
    it {should belong_to :merchant}
    it {should have_many :transactions}
    it {should have_many :invoiceItems}
  end

  describe 'validations' do
    it {should validate_presence_of(:status)}
  end

  describe 'class methods' do
    it 'finds all invoices for a particular merchant by status' do
      merchant1 = Merchant.create(name: "Little Shop of Horrors")
      bob = Customer.create!(first_name: "Bob", last_name: "Tucker")
      invoice1 = Invoice.create!(customer_id: bob.id, merchant_id: merchant1.id, status: "shipped")
      invoice2 = Invoice.create!(customer_id: bob.id, merchant_id: merchant1.id, status: "shipped")
      invoice3 = Invoice.create!(customer_id: bob.id, merchant_id: merchant1.id, status: "shipped")
      invoice4 = Invoice.create!(customer_id: bob.id, merchant_id: merchant1.id, status: "packaged")

      invoices = Invoice.find_by_status("shipped")

      expect(invoices.length).to eq(3)
      expect(invoices).to include(invoice1, invoice2, invoice3)
    end
  end
end