require 'rails_helper'

describe "Merchants" do
  before :each do
    @merchant1 = Merchant.create(name: "Little Shop of Horrors")
    @merchant2 = Merchant.create(name: "Large Shop of Wonders")
  end

  it 'can get a merchant' do
    binding.pry
    get "/api/v1/merchants/#{@merchant1.id}"
    merchant = JSON.parse(response.body)

    expect(merchant[data]).to have_key("id")
    expect(merchant["data"]["id"]).to be_an(Integer)

    expect(merchant["data"]["attributes"]).to have_key("name")
    expect(merchant["data"]["attributes"]["name"]).to be_a(String)
  end
end