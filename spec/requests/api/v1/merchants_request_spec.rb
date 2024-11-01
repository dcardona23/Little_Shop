require 'rails_helper'

describe "Merchants" do
  before :each do
    @merchant1 = Merchant.create(name: "Little Shop of Horrors")
    @merchant2 = Merchant.create(name: "Large Shop of Wonders")
    @merchant3 = Merchant.create(name: "Wizard's Chest")
  end

  it 'can get all merchants, sorted by time of creation' do
    get '/api/v1/merchants?sorted=age'
    merchants = JSON.parse(response.body, symbolize_names: true)

    expect(response).to be_successful
    expect(merchants[:data][0][:attributes][:name]).to eq("Little Shop of Horrors")
    expect(merchants[:data][1][:attributes][:name]).to eq("Large Shop of Wonders")
    expect(merchants[:data][2][:attributes][:name]).to eq("Wizard's Chest")
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

  it 'can update a merchant' do
    id = @merchant1.id
    old_merchant_name = @merchant1.name
    merchant_params = { name: "Scary Shoppe of Horrors" }
    headers = { "CONTENT_TYPE" => "application/json" }
    
    patch "/api/v1/merchants/#{id}", headers: headers, params: JSON.generate({merchant: merchant_params})
    
    @merchant1.reload

    expect(response).to be_successful
    expect(@merchant1.name).to_not eq(old_merchant_name)
    expect(@merchant1.name).to eq("Scary Shoppe of Horrors")
  end

  describe 'sad paths' do
    it 'has a sad path for not finding a merchant' do
      get "/api/v1/merchants/99999999"

      expect(response).to have_http_status(:not_found)

      data = JSON.parse(response.body, symbolize_names: true)

      expect(data[:message]).to eq("Your query could not be completed")
      expect(data[:errors]).to be_an(Array)
      expect(data[:errors][0][:status]).to eq("404")
      expect(data[:errors][0][:title]).to include("Couldn't find Merchant")
    end

    it 'has a sad path for creating a merchant without required parameters' do
      headers = { "CONTENT_TYPE" => "application/json" }
      post "/api/v1/merchants", headers: headers, params: JSON.generate({})

      expect(response).to have_http_status(:bad_request)

      data = JSON.parse(response.body, symbolize_names: true)
      
      expect(data[:message]).to eq("Your query could not be completed")
      expect(data[:errors]).to be_an(Array)
      expect(data[:errors][0]).to eq("param is missing or the value is empty: merchant")
    end

    it 'has a sad path for trying to update a merchant with invalid paramaters' do
      id = @merchant1.id
      merchant_params = { name: "" }
      headers = { "CONTENT_TYPE" => "application/json" }

      patch "/api/v1/merchants/#{id}", headers: headers, params: JSON.generate({ merchant: merchant_params })

      expect(response).to have_http_status(:bad_request)

      data = JSON.parse(response.body, symbolize_names: true)

      expect(data[:message]).to eq("Your query could not be completed")
      expect(data[:errors]).to be_an(Array)
      expect(data[:errors][0]).to eq("Name can't be blank")
    end
  end
end