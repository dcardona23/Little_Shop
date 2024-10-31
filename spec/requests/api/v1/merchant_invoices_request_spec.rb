require 'rails_helper'

describe "MerchantInvoices" do
  before :each do
    @merchant1 = Merchant.create(name: "Little Shop of Horrors")
    @merchant2 = Merchant.create(name: "Large Shop of Wonders")
    @merchant3 = Merchant.create(name: "Wizard's Chest")
  end

  it 'returns all invoices for a given merchant' do
    merchant = Merchant.create!(name: "Test Merchant")
    bob = Customer.create!(first_name: "Bob", last_name: "Tucker")
    kathy = Customer.create!(first_name: "Kathy", last_name: "Tucker")
    invoice1 = Invoice.create!(customer_id: bob.id, merchant_id: merchant.id, status: "shipped")
    invoice2 = Invoice.create!(customer_id: kathy.id, merchant_id: merchant.id, status: "shipped")

    get "/api/v1/merchants/#{merchant.id}/invoices?status=shipped"
    
    expect(response).to be_successful

    response_data = JSON.parse(response.body, symbolize_names: true)
    expect(response_data[:data].count).to eq(2)
  end

  it 'gets all merchants with returned items' do
    bob = Customer.create!(first_name: "Bob", last_name: "Tucker")
    kathy = Customer.create!(first_name: "Kathy", last_name: "Tucker")
    invoice1 = Invoice.create!(customer_id: bob.id, merchant_id: @merchant1.id, status: "returned")
    invoice2 = Invoice.create!(customer_id: kathy.id, merchant_id: @merchant2.id, status: "shipped")

    get "/api/v1/merchants?status=returned"

    expect(response).to be_successful

    response_data = JSON.parse(response.body, symbolize_names: true)
    # binding.pry
    expect(response_data[:data].count).to eq(1)
  end

  describe 'sad paths' do 
    context 'when the merchant does not exist' do
      it 'returns an error for an invalid merchant id' do
        merchant = Merchant.create!(name: "Test Merchant")
        get "/api/v1/merchants/#{merchant.id + 1}/invoices?status=returned"
    
        expect(response).not_to be_successful
        expect(response).to have_http_status(:not_found)
    
        data = JSON.parse(response.body, symbolize_names: true)

        expect(data[:errors]).to be_an(Array)
        expect(data[:message]).to eq("your query could not be completed")
        expect(data[:errors][0]).to eq("merchant not found")
      end
    end

    context 'when there are no invoices with the specified status' do
      it 'returns an error if there are no invoices with the specified status' do
        merchant = Merchant.create!(name: "Test Merchant")
        get "/api/v1/merchants/#{merchant.id}/invoices?status=returned"
        
        expect(response).not_to be_successful
        expect(response.status).to eq(404)
    
        data = JSON.parse(response.body, symbolize_names: true)
    
        expect(data[:errors]).to be_an(Array)
        expect(data[:message]).to eq("your query could not be completed")
        expect(data[:errors][0]).to eq("no invoices found with status returned")
      end
    end 
  end
end