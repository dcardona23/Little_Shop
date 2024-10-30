require 'rails_helper'

describe "Merchants" do
  before :each do
    @merchant1 = Merchant.create(name: "Little Shop of Horrors")
    @merchant2 = Merchant.create(name: "Large Shop of Wonders")
    @merchant3 = Merchant.create(name: "Wizard's Chest")

    @invoice1 = Invoice.create(customer_id: 1, merchant_id: @merchant1.id, status: "shipped")
  end

  it 'can get a merchant' do
    get "/api/v1/merchants/#{@merchant1.id}"
    merchant = JSON.parse(response.body)
    
    expect(merchant["data"]).to have_key("id")
    expect(merchant["data"]["attributes"]).to have_key("name")
    expect(merchant["data"]["attributes"]["name"]).to eq(@merchant1.name)
  end

  it 'can create a new merchant' do
    merchant_params = {
      name: "Susan"
      }

    headers = {"CONTENT_TYPE" => "application/json"}
    post "/api/v1/merchants", headers: headers, params: JSON.generate(merchant: merchant_params)

    new_merchant = Merchant.last

    expect(response).to be_successful
    expect(new_merchant.name).to eq(merchant_params[:name])
    end

    it 'can delete a merchant' do
      delete "/api/v1/merchants/#{@merchant1.id}"

      expect(response).to be_successful
      expect{Merchant.find(@merchant1.id)}.to raise_error(ActiveRecord::RecordNotFound)
    end

  it 'can sort all merchants by time of creation' do
    get '/api/v1/merchants?sorted=age'
    merchants = JSON.parse(response.body, symbolize_names: true)

    expect(response).to be_successful
    expect(merchants[:data][0][:attributes][:name]).to eq("Little Shop of Horrors")
    expect(merchants[:data][1][:attributes][:name]).to eq("Large Shop of Wonders")
    expect(merchants[:data][2][:attributes][:name]).to eq("Wizard's Chest")
  end

  it 'returns all invoices for a given merchant' do
    merchant_id = @merchant1.id
    get "/api/v1/merchants/#{merchant_id}/invoices?status=shipped"


  end

end