require 'rails_helper'

describe "items_merchants" do
  before(:each) do
    @merchant1 = Merchant.create(
      name: "Susan"
    )
    @merchant2 = Merchant.create(
      name: "Steve"
    )
    @item1 = Item.create({
      name: "apple",
      description: "is am apple",
      unit_price: 0.50,
      merchant_id: @merchant1[:id]
    })
    
    @item2 = Item.create({
      name: "cherry",
      description: "is am cherry",
      unit_price: 1.50,
      merchant_id: @merchant2[:id]
    })
    
    @item3 = Item.create({
      name: "pear",
      description: "is am pear",
      unit_price: 0.75,
      merchant_id: @merchant1[:id]
    })
    
    @item4 = Item.create({
      name: "banana",
      description: "is am banaa",
      unit_price: 3.50,
      merchant_id: @merchant2[:id]
    })
  end

  describe "#index" do
    it "can get a merchant associated to an item" do
      get "/api/v1/items/#{@item1.id}/merchant"
      expect(response).to be_successful

      merchant = JSON.parse(response.body, symbolize_names: true)

      expect(merchant[:data]).to have_key(:id)
      expect(merchant[:data][:attributes]).to have_key(:name)
      expect(merchant[:data][:attributes][:name]).to eq(@merchant1[:name])

      get "/api/v1/items/#{@item2.id}/merchant"
      expect(response).to be_successful

      merchant2 = JSON.parse(response.body, symbolize_names: true)

      expect(merchant2[:data]).to have_key(:id)
      expect(merchant2[:data][:attributes]).to have_key(:name)
      expect(merchant2[:data][:attributes][:name]).to eq(@merchant2[:name])
    end

    it "can't get a merchant associated to an item (Sad path)" do
      get "/api/v1/items/#{@item1.id + 999999}/merchant"

      expect(response).to have_http_status(:not_found)
      
      data = JSON.parse(response.body, symbolize_names: true)
      
      expect(data[:message]).to eq("Your query could not be completed")

      expect(data[:errors]).to be_an(Array)
      expect(data[:errors][0][:title]).to eq("Couldn't find Item with 'id'=#{@item1.id + 999999}")
    end
  end
end