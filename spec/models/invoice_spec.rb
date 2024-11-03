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
      invoice5 = Invoice.create!(customer_id: bob.id, merchant_id: merchant1.id, status: "packaged")

      shipped_invoices = Invoice.find_by_status("shipped")
      expect(shipped_invoices.length).to eq(3)
      expect(shipped_invoices).to include(invoice1, invoice2, invoice3)
      expect(shipped_invoices).not_to include(invoice4, invoice5)

      packaged_invoices = Invoice.find_by_status("packaged")
      expect(packaged_invoices.length).to eq(2)
      expect(packaged_invoices).to include(invoice4, invoice5)
      expect(packaged_invoices).not_to include(invoice1, invoice2, invoice3)
      
      returned_invoices = Invoice.find_by_status("returned")
      expect(returned_invoices).to be_empty

      unknown_invoices = Invoice.find_by_status("unknown status")
      expect(unknown_invoices).to be_empty
    end

    it 'returns an empty result for a nil status input' do
      result = Invoice.find_by_status(nil)
      expect(result).to be_empty
    end

    it 'returns an empty result for an empty string status input' do
      result = Invoice.find_by_status("")
      expect(result).to be_empty
    end
  end
end