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
    
    expect(response_data[:data].count).to eq(1)
  end

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