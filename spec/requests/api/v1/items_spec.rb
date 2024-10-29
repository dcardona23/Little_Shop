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
    sleep(1)
    @item2 = Item.create({
      name: "cherry",
      description: "is am cherry",
      unit_price: 1.50,
      merchant_id: id2
    })
    sleep(1)
    @item3 = Item.create({
      name: "pear",
      description: "is am pear",
      unit_price: 0.75,
      merchant_id: id
    })
    sleep(1)
    @item4 = Item.create({
      name: "banana",
      description: "is am banaa",
      unit_price: 3.50,
      merchant_id: id2
    })
  end

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

  it 'can create new items' do
    params = {
      name: "potatoe",
      description: "am potatoe",
      unit_price: 3.50,
      merchant_id: @id2
    }

    post '/api/v1/items', params: {item: params}

    expect(response).to be_successful
    item_created = JSON.parse(response.body, symbolize_names: true)
    id = item_created[:data]
    expect(item_created[:data]).to have_key(:id)
    expect(item_created[:data][:id]).to be_an(String)

    expect(item_created[:data][:attributes]).to have_key(:name)
    expect(item_created[:data][:attributes][:name]).to be_a(String)

    expect(item_created[:data][:attributes]).to have_key(:description)
    expect(item_created[:data][:attributes][:description]).to be_a(String)

    expect(item_created[:data][:attributes]).to have_key(:unit_price)
    expect(item_created[:attributes][:unit_price]).to be_a(Float)

    expect(item_created[:data][:attributes]).to have_key(:merchant_id)
    expect(item_created[:data][:attributes][:merchant_id]).to be_a(Integer)

    get "/api/v1/items"
    all_items = JSON.parse(response.body, symbolize_names: true)

    expect(item_created[:data][:attributes][:name]).to eq("potatoe")
    expect(item_created[:data][:attributes][:description]).to eq("am potatoe")
    expect(all_items[:data]).to include(id)
  end
end