require 'rails_helper'

RSpec.describe Invoice do

  describe 'relationships' do
    it {should belong_to :customer}
    it {should belong_to :merchant}
    it {should have_many :transactions}
    it {should have_many :invoice_items}
  end

  describe 'validations' do
    it {should validate_presence_of(:status)}
  end
    
  describe 'class and instance methods' do
    before(:each) do
      @merchant1 = Merchant.create(name: "Little Shop of Horrors")
      @merchant2 = Merchant.create(name: "Gigantic Shop")

      @bob = Customer.create!(first_name: "Bob", last_name: "Tucker")

      @item1 = Item.create({
        name: "apple",
        description: "is an apple",
        unit_price: 0.50,
        merchant_id: @merchant1.id
        })
      
      @item2 = Item.create({
        name: "cherry",
        description: "is a cherry",
        unit_price: 1.50,
        merchant_id: @merchant1.id
      })
      
      @item3 = Item.create({
        name: "pear",
        description: "is a pear",
        unit_price: 0.75,
        merchant_id: @merchant1.id
      })

      @invoice1 = Invoice.create!(customer_id: @bob.id, merchant_id: @merchant1.id, status: "shipped")
      @invoice2 = Invoice.create!(customer_id: @bob.id, merchant_id: @merchant1.id, status: "shipped")
      @invoice3 = Invoice.create!(customer_id: @bob.id, merchant_id: @merchant1.id, status: "shipped")
      @invoice4 = Invoice.create!(customer_id: @bob.id, merchant_id: @merchant1.id, status: "packaged")
      @invoice5 = Invoice.create!(customer_id: @bob.id, merchant_id: @merchant2.id, status: "packaged")

      @invoice_item1 = InvoiceItem.create!(
        quantity: 100,
        unit_price: @item1.unit_price,
        item_id: @item1.id,
        invoice_id: @invoice1.id
      )

      @invoice_item2 = InvoiceItem.create!(
        quantity: 500,
        unit_price: @item2.unit_price,
        item_id: @item2.id,
        invoice_id: @invoice1.id
      )

      @invoice_item3 = InvoiceItem.create!(
        quantity: 45,
        unit_price: @item3.unit_price,
        item_id: @item3.id,
        invoice_id: @invoice2.id
      )

      @invoice_item4 = InvoiceItem.create!(
        quantity: 76,
        unit_price: @item1.unit_price,
        item_id: @item1.id,
        invoice_id: @invoice2.id
      )

      @coupon1 = Coupon.create!(
      name: Faker::Commerce.product_name,
      code: Faker::Commerce.promotion_code,
      percent_off: 25,
      dollar_off: nil,
      merchant_id: @merchant1.id, 
      active: true
      )

      @coupon2 = Coupon.create!(
      name: Faker::Commerce.product_name,
      code: Faker::Commerce.promotion_code,
      percent_off: nil,
      dollar_off: 100,
      merchant_id: @merchant1.id, 
      active: true
      )

      @invoice1.update!(coupon_id: @coupon1.id)
      @invoice2.update!(coupon_id: @coupon2.id)

    end

    it 'finds all invoices for a particular merchant by status' do
      shipped_invoices = Invoice.find_by_status("shipped")
      expect(shipped_invoices.length).to eq(3)
      expect(shipped_invoices).to include(@invoice1, @invoice2, @invoice3)
      expect(shipped_invoices).not_to include(@invoice4, @invoice5)

      packaged_invoices = Invoice.find_by_status("packaged")
      expect(packaged_invoices.length).to eq(2)
      expect(packaged_invoices).to include(@invoice4, @invoice5)
      expect(packaged_invoices).not_to include(@invoice1, @invoice2, @invoice3)
      
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

    it 'calculates the cost of all items on an invoice' do

      expect(@invoice1.invoice_subtotal).to eq(800)
    end

    it 'calculates the total cost with coupons' do

      expect(@invoice1.discount_total).to eq(200)
      expect(@invoice1.total_invoice_cost).to eq(600)
    end

    it 'will not let the total cost be negative' do

      expect(@invoice2.invoice_subtotal).to eq(71.75)
      expect(@invoice2.discount_total).to eq(71.75)
      expect(@invoice2.total_invoice_cost).to eq(0)
    end

    it 'requires that a merchant sell an item on the invoice before applying a coupon' do
      @invoice5.coupon = @coupon1 
      
      expect(@invoice5).not_to be_valid
      expect(@invoice5.errors[:coupon]).to include("Merchant does not sell an item on this invoice to which the coupon can be applied")
    end
  end
end