require 'rails_helper'

describe "items" do
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
      expect(data[:errors][0][:status]).to eq("404")
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
      expect(data[:message]).to eq("Your query could not be completed")
      expect(data[:errors][0]).to include("Merchant must exist")
    end
  end

  describe "#create and #destroy" do
    it 'can create new items and deletes' do
      params = {
        name: "potatoe",
        description: "am potatoe",
        unit_price: 3.50,
        merchant_id: @merchant2[:id]
      }

      post '/api/v1/items', params: {item: params}

      expect(response).to be_successful
      item_created = JSON.parse(response.body, symbolize_names: true)
      item = item_created[:data]
      item_id = item_created[:data][:id]
      expect(item_created[:data]).to have_key(:id)
      expect(item_created[:data][:id]).to be_an(String)

      expect(item_created[:data][:attributes]).to have_key(:name)
      expect(item_created[:data][:attributes][:name]).to be_a(String)

      expect(item_created[:data][:attributes]).to have_key(:description)
      expect(item_created[:data][:attributes][:description]).to be_a(String)

      expect(item_created[:data][:attributes]).to have_key(:unit_price)
      expect(item_created[:data][:attributes][:unit_price]).to be_a(Float)

      expect(item_created[:data][:attributes]).to have_key(:merchant_id)
      expect(item_created[:data][:attributes][:merchant_id]).to be_a(Integer)

      get "/api/v1/items"
      all_items = JSON.parse(response.body, symbolize_names: true)

      expect(item_created[:data][:attributes][:name]).to eq("potatoe")
      expect(item_created[:data][:attributes][:description]).to eq("am potatoe")
      expect(all_items[:data]).to include(item)

      delete "/api/v1/items/#{item_id.to_i}"
      expect(response).to be_successful

      get "/api/v1/items"
      all_items_delete = JSON.parse(response.body, symbolize_names: true)

      expect(all_items_delete[:data]).not_to include(item)
    end

    describe 'has a sad path for creating' do
      it "has invalid attributes" do
        params = {
          name: "potatoe",
          description: "am potatoe",
          unit_price: 3.50,
          merchant_id: @merchant2[:id],
          potatoe_style: "rotund"
        }
  
        post '/api/v1/items', params: {item: params}
  
        expect(response).to be_successful
        item_created = JSON.parse(response.body, symbolize_names: true)
        item = item_created[:data]
        expect(item_created[:data]).to have_key(:id)
        expect(item_created[:data][:attributes]).to have_key(:name)
        expect(item_created[:data][:attributes]).to have_key(:description)
        expect(item_created[:data][:attributes]).to have_key(:unit_price)
        expect(item_created[:data][:attributes]).to have_key(:merchant_id)
        expect(item_created[:data][:attributes]).to_not have_key(:potatoe_style)

        get "/api/v1/items"
        all_items = JSON.parse(response.body, symbolize_names: true)
        expect(item_created[:data][:attributes][:name]).to eq("potatoe")
        expect(item_created[:data][:attributes][:description]).to eq("am potatoe")
        expect(all_items[:data]).to include(item)

      end

      it "is missing an attribute" do
        params = {
          name: "potatoe",
          description: "am potatoe",
          potatoe_style: "rotund"
        }
  
        post '/api/v1/items', params: {item: params}
  
        expect(response).not_to be_successful

        json_response = JSON.parse(response.body, symbolize_names: true)
        
        expect(json_response[:errors]).to be_an(Array)
        expect(json_response[:message]).to eq("Your query could not be completed")
        expect(json_response[:errors][0]).to include("Merchant must exist")
      end
    end
  end

  describe "can handle  parameters" do
    it "SAD cant find negative min price" do
      get "/api/v1/items/find_all?min_price=-3.2"

      expect(response).not_to be_successful
      expect(response).to have_http_status(400)
      json_response = JSON.parse(response.body, symbolize_names: true)
    
      expect(json_response[:errors]).to be_an(Array)
      expect(json_response[:message]).to eq("Your query could not be completed")
      expect(json_response[:errors][0][:title]).to include("Cannot have a negative number for min_price")
    end

    it "SAD cant find max price 0 or less" do
      get "/api/v1/items/find_all?max_price=-3.2"

      expect(response).not_to be_successful
      expect(response).to have_http_status(400)
      json_response = JSON.parse(response.body, symbolize_names: true)
    
      expect(json_response[:errors]).to be_an(Array)
      expect(json_response[:message]).to eq("Your query could not be completed")
      expect(json_response[:errors][0][:title]).to include("Max price cannot be 0 or lower than 0")

    end

    it "SAD cant look for a name and a price at same time" do
      get "/api/v1/items/find_all?max_price=5.20&name=apple"

      expect(response).not_to be_successful
      expect(response).to have_http_status(400)
      json_response = JSON.parse(response.body, symbolize_names: true)
    
      expect(json_response[:errors]).to be_an(Array)
      expect(json_response[:message]).to eq("Your query could not be completed")
      expect(json_response[:errors][0][:title]).to include("Cannot search for a name and price at the same time")
    end

    it "SAD cant have an empty find_all field" do
      get "/api/v1/items/find_all"

      expect(response).not_to be_successful
      expect(response).to have_http_status(400)
      json_response = JSON.parse(response.body, symbolize_names: true)
      expect(json_response[:errors]).to be_an(Array)
      expect(json_response[:message]).to eq("Your query could not be completed")
      expect(json_response[:errors][0][:title]).to include("Find All parameters cannot be empty")
    end

    it "SAD cant have an empty name field" do
      get "/api/v1/items/find_all?name="

      expect(response).not_to be_successful
      expect(response).to have_http_status(400)
      json_response = JSON.parse(response.body, symbolize_names: true)
      expect(json_response[:errors]).to be_an(Array)
      expect(json_response[:message]).to eq("Your query could not be completed")
      expect(json_response[:errors][0][:title]).to include("Name input cannot be empty")

    end

    it "HAPPY! can look for both a min and max price" do
      get "/api/v1/items/find_all?max_price=2.00&min_price=0.60"

      expect(response).to be_successful
      expect(response).to have_http_status(200)
      json_response = JSON.parse(response.body, symbolize_names: true)
      
      expect(json_response[:data].count).to eq(2)
    end

    it "HAPPY! can look for a name" do
      get "/api/v1/items/find_all?name=a"

      expect(response).to be_successful
      expect(response).to have_http_status(200)
      json_response = JSON.parse(response.body, symbolize_names: true)

      expect(json_response[:data].count).to eq(3)

    end
  end
end