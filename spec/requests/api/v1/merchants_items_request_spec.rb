require 'rails_helper'

describe "merchants_items" do
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
    it "can get all items associated to a merchant" do
      get "/api/v1/merchants/#{@merchant1[:id]}/items"
      expect(response).to be_successful

      items = JSON.parse(response.body, symbolize_names: true)

      expect(items[:data].count).to eq(2)
      expect(items[:meta]).to have_key(:count)
      expect(items[:meta][:count]).to equal(items[:data].count)

      items[:data].each do |item|
        expect(item).to have_key(:id)
        expect(item[:id]).to be_an(String)

        expect(item[:attributes]).to have_key(:name)
        expect(item[:attributes][:name]).to be_a(String)

        expect(item[:attributes]).to have_key(:description)
        expect(item[:attributes][:description]).to be_a(String)

        expect(item[:attributes]).to have_key(:unit_price)
        expect(item[:attributes][:unit_price]).to be_a(Float)

        expect(item[:attributes]).to have_key(:merchant_id)
        expect(item[:attributes][:merchant_id]).to be_a(Integer)
      end

    end

    it "can't get all items associated to a merchant (Sad path)" do
      get "/api/v1/merchants/#{@merchant1[:id] + 9999999999}/items"
      expect(response).not_to be_successful
      id = @merchant1[:id] + 9999999999
      data = JSON.parse(response.body, symbolize_names: true)
      
      expect(data[:errors]).to be_an(Array)
      expect(data[:errors][0][:status]).to eq("404")
      expect(data[:errors][0][:title]).to include("Couldn't find Merchant with 'id'=#{id}")
    end
  end

end