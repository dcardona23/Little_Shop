require 'rails_helper'

describe "items" do
  before(:each) do
    id = Merchant.create(
      name: "Susan"
    ).id
    id2 = Merchant.create(
      name: "Steve"
    ).id
    @item1 = Item.create({
      name: "apple",
      description: "is am apple",
      unit_price: 0.50,
      merchant_id: id
    })
    
    @item2 = Item.create({
      name: "cherry",
      description: "is am cherry",
      unit_price: 1.50,
      merchant_id: id2
    })
    
    @item3 = Item.create({
      name: "pear",
      description: "is am pear",
      unit_price: 0.75,
      merchant_id: id
    })
    
    @item4 = Item.create({
      name: "banana",
      description: "is am banaa",
      unit_price: 3.50,
      merchant_id: id2
    })
  end

  describe "#index" do
    it "can call all items" do
      get '/api/v1/items'
      expect(response).to be_successful
      items = JSON.parse(response.body, symbolize_names: true)
    
      expect(items[:data].count).to eq(4)
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

    it 'can sort by price' do
      get '/api/v1/items'
      expect(response).to be_successful
      items = JSON.parse(response.body, symbolize_names: true)

      expect(items[:data][0][:attributes][:unit_price]).to eq(0.50)
      expect(items[:data][1][:attributes][:unit_price]).to eq(1.50)
      expect(items[:data][2][:attributes][:unit_price]).to eq(0.75)
      expect(items[:data][3][:attributes][:unit_price]).to eq(3.50)

      get '/api/v1/items?sorted=price'
      expect(response).to be_successful
      items_sorted = JSON.parse(response.body, symbolize_names: true)

      expect(items_sorted[:data][0][:attributes][:unit_price]).to eq(0.50)
      expect(items_sorted[:data][1][:attributes][:unit_price]).to eq(0.75)
      expect(items_sorted[:data][2][:attributes][:unit_price]).to eq(1.50)
      expect(items_sorted[:data][3][:attributes][:unit_price]).to eq(3.50)
    end
  end

  describe "#show" do
    it "can get one item by #id" do
      get "/api/v1/items/#{@item1.id}"

      expect(response).to be_successful

      item = JSON.parse(response.body, symbolize_names: true)

      expect(item[:data]).to have_key(:id)
      expect(item[:data][:id]).to be_an(String)

      expect(item[:data][:attributes]).to have_key(:name)
      expect(item[:data][:attributes][:name]).to be_a(String)

      expect(item[:data][:attributes]).to have_key(:description)
      expect(item[:data][:attributes][:description]).to be_a(String)

      expect(item[:data][:attributes]).to have_key(:unit_price)
      expect(item[:data][:attributes][:unit_price]).to be_a(Float)

      expect(item[:data][:attributes]).to have_key(:merchant_id)
      expect(item[:data][:attributes][:merchant_id]).to be_a(Integer)
    end

    it "has a sad path for not finding one item" do
      get "/api/v1/items/#{@item1.id + 999999}"
      
      expect(response).to have_http_status(:not_found)
      
      data = JSON.parse(response.body, symbolize_names: true)
      
      expect(data[:errors]).to be_an(Array)
      expect(data[:errors][0][:status]).to eq(404)
      expect(data[:errors][0][:title]).to include("Couldn't find Item")
    end
  end

  describe "#update" do
    it "can update items" do
      updated_attributes = {
        name: "I am spork",
        description: "Fork and spoon",
        unit_price: 1.99,
        merchant_id: @item1.merchant_id
      }

      patch "/api/v1/items/#{@item1.id}", params: { item: updated_attributes }

      expect(response).to be_successful

      item = JSON.parse(response.body, symbolize_names: true)

      expect(item[:data][:attributes][:name]).to eq("I am spork")
      expect(item[:data][:attributes][:description]).to eq("Fork and spoon")
      expect(item[:data][:attributes][:unit_price]).to eq(1.99)
      expect(item[:data][:attributes][:merchant_id]).to eq(@item1.merchant_id)
    end

    it "can handle sad path for no merchant_id" do
      updated_attributes = { merchant_id: 999999 }

      patch "/api/v1/items/#{@item1.id}", params: { item: updated_attributes }

      expect(response).to have_http_status(:not_found)

      data = JSON.parse(response.body, symbolize_names: true)

      expect(data[:errors]).to be_an(Array)
      expect(data[:errors][0][:status]).to eq(404)
      expect(data[:errors][0][:title]).to include("Merchant must exist")
    end
  end
end