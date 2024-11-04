require 'rails_helper'

RSpec.describe Customer, type: :model do
  describe 'relationships' do
    it { should have_many :invoices }
  end

  describe 'validations' do
    it { should validate_presence_of(:first_name) }
    it { should validate_presence_of(:last_name) }
  end

  describe 'class methods' do
    before(:each) do
      @merchant = Merchant.create!(name: "Little Shop of Horrors")
      @other_merchant = Merchant.create!(name: "Big Shop of Wonders")

      @customer1 = Customer.create!(first_name: "Alice", last_name: "Smith")
      @customer2 = Customer.create!(first_name: "John", last_name: "Doe")

      @invoice1 = Invoice.create!(customer_id: @customer1.id, merchant_id: @merchant.id, status: "shipped")
      @invoice2 = Invoice.create!(customer_id: @customer2.id, merchant_id: @merchant.id, status: "shipped")
      @duplicate_invoice = Invoice.create!(customer_id: @customer1.id, merchant_id: @merchant.id, status: "shipped")
      
      @other_merchant_invoice = Invoice.create!(customer_id: @customer1.id, merchant_id: @other_merchant.id, status: "packaged")
    end

    describe '.customersForMerchant' do
      it 'returns unique customers associated with a particular merchant' do
        result = Customer.customersForMerchant(@merchant.id)
        
        expect(result).to contain_exactly(@customer1, @customer2)
      end

      it 'does not include customers associated only with other merchants' do
        new_customer = Customer.create!(first_name: "Charlie", last_name: "Brown")
        Invoice.create!(customer_id: new_customer.id, merchant_id: @other_merchant.id, status: "shipped")
        
        result = Customer.customersForMerchant(@merchant.id)
        
        expect(result).to contain_exactly(@customer1, @customer2)
      end
    end
  end
end
