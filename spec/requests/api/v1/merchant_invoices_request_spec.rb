require 'rails_helper'

describe "MerchantInvoices" do
  before :each do
    @merchant1 = Merchant.create(name: "Little Shop of Horrors")
    @merchant2 = Merchant.create(name: "Large Shop of Wonders")
    @merchant3 = Merchant.create(name: "Wizard's Chest")

    @bob = Customer.create!(first_name: "Bob", last_name: "Tucker")
    @kathy = Customer.create!(first_name: "Kathy", last_name: "Tucker")

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
    merchant_id: @merchant2.id, 
    active: true
    )
  end

  describe 'fetching merchants and invoices' do
    it 'returns all invoices for a given merchant' do
      merchant = Merchant.create!(name: "Test Merchant")
      
      invoice1 = Invoice.create!(customer_id: @bob.id, merchant_id: merchant.id, status: "shipped")
      invoice2 = Invoice.create!(customer_id: @kathy.id, merchant_id: merchant.id, status: "shipped")

      get "/api/v1/merchants/#{merchant.id}/invoices?status=shipped"
      
      expect(response).to be_successful

      response_data = JSON.parse(response.body, symbolize_names: true)
      expect(response_data[:data].count).to eq(2)
    end

    it 'gets all merchants with returned items' do
      invoice1 = Invoice.create!(customer_id: @bob.id, merchant_id: @merchant1.id, status: "returned")
      invoice2 = Invoice.create!(customer_id: @kathy.id, merchant_id: @merchant2.id, status: "shipped")

      get "/api/v1/merchants?status=returned"

      expect(response).to be_successful

      response_data = JSON.parse(response.body, symbolize_names: true)
      
      expect(response_data[:data].count).to eq(1)
    end
  end

  describe 'creating invoices' do
    it 'successfully creates an invoice with a coupon when the merchant sells items on the invoice' do
      @valid_invoice = Invoice.create!(customer_id: @bob.id, merchant_id: @merchant1.id, status: "returned")
      InvoiceItem.create!(invoice: @valid_invoice, item: @item1, quantity: 1, unit_price: @item1.unit_price)
      @valid_invoice.update!(coupon_id: @coupon1.id)

      @no_coupon_invoice = Invoice.create!(customer_id: @bob.id, merchant_id: @merchant1.id, status: "returned")
      InvoiceItem.create!(invoice: @no_coupon_invoice, item: @item1, quantity: 1, unit_price: @item1.unit_price)

      get "/api/v1/merchants/#{@merchant1.id}/invoices"
      
      expect(response).to have_http_status(200)
      invoices = JSON.parse(response.body)

      expect(invoices['data'].length).to eq(2)
      invoice_ids = invoices['data'].map { |invoice| invoice['id'].to_i }
      expect(invoice_ids).to include(@valid_invoice.id, @no_coupon_invoice.id)
    end

    it 'fails to create an invoice with a coupon when the merchant does not sell items on the invoice' do
      
      @invalid_invoice = Invoice.create!(customer_id: @bob.id, merchant_id: @merchant1.id, status: "packaged")
      InvoiceItem.create!(invoice: @invalid_invoice, item: @item1, quantity: 1, unit_price: @item1.unit_price)
      
      expect(@invalid_invoice.update(coupon_id: @coupon2.id)).to be false
      expect(@invalid_invoice.errors[:coupon]).to include("Merchant does not sell an item on this invoice to which the coupon can be applied")
    end
  end

  describe 'sad paths' do 
    it 'has a sad path for not finding a status' do
      get "/api/v1/merchants/#{@merchant1.id}/invoices", params: { status: "no_status" }

      expect(response).to have_http_status(:not_found)

      response_data = JSON.parse(response.body, symbolize_names: true)
    
      expect(response_data[:message]).to eq("Your query could not be completed")
      expect(response_data[:errors][0][:title]).to eq("No invoices found with status no_status")
    end

    it 'has a sad path for when the merchant id is not found' do
      get "/api/v1/merchants/99999999/invoices"

      expect(response).to have_http_status(:not_found)
      response_data = JSON.parse(response.body, symbolize_names: true)

      expect(response_data[:message]).to eq("Your query could not be completed")
      expect(response_data[:errors]).to be_an(Array)
      expect(response_data[:errors][0][:status]).to eq("404")
      expect(response_data[:errors][0][:title]).to include("Couldn't find Merchant")
    end
  end
end