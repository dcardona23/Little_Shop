require 'rails_helper'

describe "Merchants" do
  before :each do
    @merchant1 = Merchant.create(name: "Little Shop of Horrors")
    @merchant2 = Merchant.create(name: "Large Shop of Wonders")
  end

  it 'can get a merchant' do
    get "/api/v1/merchants/#{@merchant1.id}"
    merchant = JSON.parse(response.body)
    
    binding.pry
    expect(merchant["data"]).to have_key("id")
    expect(merchant["data"]["attributes"]).to have_key("name")
    expect(merchant["data"]["attributes"]["name"]).to eq(@merchant1.name)
  end
end