require 'rails_helper'

describe "Merchants" do
  before :each do
    @merchant1 = Merchant.create(name: "Little Shop of Horrors")
    @merchant2 = Merchant.create(name: "Large Shop of Wonders")
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
      expect(Merchant.find(@merchant1.id)).to raise_error(ActiveRecord::RecordNotFound)
    end
end