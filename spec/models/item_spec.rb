require 'rails_helper'

RSpec.describe Item do
  before(:all) do
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

  after(:all) do
    Item.delete_all
    Merchant.delete_all
  end

  describe 'relationships' do
    it {should belong_to :merchant}
    it {should have_many :invoiceItems}
  end

  describe 'validations' do
    it {should validate_presence_of(:name)}
    it {should validate_presence_of(:description)}
    it {should validate_presence_of(:unit_price)}
  end

  describe 'class methods' do
    it 'sorts items by price' do
      expect(Item.all[0][:unit_price]).to eq(0.50)
      expect(Item.all[1][:unit_price]).to eq(1.50)
      expect(Item.all[2][:unit_price]).to eq(0.75)
      expect(Item.all[3][:unit_price]).to eq(3.50)
      params = {sorted: "price"}
      items_sorted = Item.sort_items(Item.all, params)

      expect(items_sorted[0][:unit_price]).to eq(0.50)
      # expect(items_sorted[1][:unit_price]).to eq(0.75)
      expect(items_sorted[2][:unit_price]).to eq(1.50)
      expect(items_sorted[3][:unit_price]).to eq(3.50)
      params = {sorted: nil}
      items_sorted_not = Item.sort_items(Item.all, params)
      expect(items_sorted_not[0][:unit_price]).to eq(0.50)
      expect(items_sorted_not[1][:unit_price]).to eq(1.50)
      expect(items_sorted_not[2][:unit_price]).to eq(0.75)
      expect(items_sorted_not[3][:unit_price]).to eq(3.50)
    end

    it 'finds all items by name fragment' do
      item5 = Item.create({
      name: "Copper pot", 
      description: Faker::Lorem.sentence,
      unit_price: Faker::Commerce.price(range: 1.0..55.00),
      merchant_id: @merchant1[:id]
    })
    
    item6 = Item.create({
      name: "Copper kettle",
      description: Faker::Lorem.sentence,
      unit_price: Faker::Commerce.price(range: 1.0..55.00),
      merchant_id: @merchant2[:id]
    })
    
    item7 = Item.create({
      name: "copper plate",
      description: Faker::Lorem.sentence,
      unit_price: Faker::Commerce.price(range: 1.0..55.00),
      merchant_id: @merchant1[:id]
    })

    item8 = Item.create({
      name: "iron fist",
      description: Faker::Lorem.sentence,
      unit_price: Faker::Commerce.price(range: 1.0..55.00),
      merchant_id: @merchant1[:id]
    })

    item9 = Item.create({
      name: "silver sword",
      description: Faker::Lorem.sentence,
      unit_price: Faker::Commerce.price(range: 1.0..55.00),
      merchant_id: @merchant1[:id]
    })
      
      expect(Item.find_by_name("copper")).to include(item5, item6, item7)
    end

    it 'find all items by case insensitive name fragment' do 
      item5 = Item.create({
        name: "Copper pot", 
        description: Faker::Lorem.sentence,
        unit_price: Faker::Commerce.price(range: 1.0..55.00),
        merchant_id: @merchant1[:id]
      })
      
      item6 = Item.create({
        name: "Copper kettle",
        description: Faker::Lorem.sentence,
        unit_price: Faker::Commerce.price(range: 1.0..55.00),
        merchant_id: @merchant2[:id]
      })
      
      item7 = Item.create({
        name: "copper plate",
        description: Faker::Lorem.sentence,
        unit_price: Faker::Commerce.price(range: 1.0..55.00),
        merchant_id: @merchant1[:id]
      })
  
      item8 = Item.create({
        name: "iron fist",
        description: Faker::Lorem.sentence,
        unit_price: Faker::Commerce.price(range: 1.0..55.00),
        merchant_id: @merchant1[:id]
      })
  
      item9 = Item.create({
        name: "silver sword",
        description: Faker::Lorem.sentence,
        unit_price: Faker::Commerce.price(range: 1.0..55.00),
        merchant_id: @merchant1[:id]
      })
        
      expect(Item.find_by_name("copPER")).to include(item5, item6, item7)
      expect(Item.find_by_name("COPper")).to include(item5, item6, item7)
      expect(Item.find_by_name("cOPPer")).to include(item5, item6, item7)
      expect(Item.find_by_name("cOpPeR")).to include(item5, item6, item7)
    end
  end
end