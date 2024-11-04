require 'rails_helper'

RSpec.describe Merchant do

  before(:each) do
    @merchant1 = Merchant.create(name: "Little Shop of Horrors")
    @merchant2 = Merchant.create(name: "Large Shop of Wonders")
    @merchant3 = Merchant.create(name: "Wizard's Chest")
  end

  describe 'relationships' do
    it {should have_many :invoices}
    it {should have_many :items}
  end

  describe 'validations' do
    it {should validate_presence_of(:name)}
  end

  describe 'class methods' do
    it 'sorts merchants by time created' do
      sorted_by_age = Merchant.sort_by_age
      
      expect(sorted_by_age[0].name).to eq("Little Shop of Horrors")
      expect(sorted_by_age[1].name).to eq("Large Shop of Wonders")
      expect(sorted_by_age[2].name).to eq("Wizard's Chest")
    end

    it 'returns all merchants that have invoices with a specified status' do
      merchant1 = Merchant.create(name: "Little Shop of Horrors")
      merchant2 = Merchant.create(name: "Large Shop of Wonders")

      bob = Customer.create!(first_name: "Bob", last_name: "Tucker")

      invoice1 = Invoice.create!(customer_id: bob.id, merchant_id: merchant1.id, status: "shipped")
      invoice2 = Invoice.create!(customer_id: bob.id, merchant_id: merchant2.id, status: "shipped")
      invoice3 = Invoice.create!(customer_id: bob.id, merchant_id: merchant1.id, status: "shipped")
      invoice4 = Invoice.create!(customer_id: bob.id, merchant_id: merchant1.id, status: "packaged")

      merchants_with_shipped = Merchant.item_status("shipped")
      merchants_with_packaged = Merchant.item_status("packaged")

      expect(merchants_with_shipped.length).to eq(2)
      expect(merchants_with_shipped).to include(merchant1, merchant2)
      expect(merchants_with_packaged.length).to eq(1)
      expect(merchants_with_packaged).to include(merchant1)
    end

    it 'only returns unique merchants that have invoices with a specified status' do
      merchant1 = Merchant.create(name: "Little Shop of Horrors")
      merchant2 = Merchant.create(name: "Large Shop of Wonders")

      bob = Customer.create!(first_name: "Bob", last_name: "Tucker")

      invoice1 = Invoice.create!(customer_id: bob.id, merchant_id: merchant1.id, status: "shipped")
      invoice1 = Invoice.create!(customer_id: bob.id, merchant_id: merchant1.id, status: "shipped")
      invoice1 = Invoice.create!(customer_id: bob.id, merchant_id: merchant1.id, status: "shipped")
      invoice1 = Invoice.create!(customer_id: bob.id, merchant_id: merchant1.id, status: "shipped")

      invoice4 = Invoice.create!(customer_id: bob.id, merchant_id: merchant2.id, status: "packaged")
      invoice4 = Invoice.create!(customer_id: bob.id, merchant_id: merchant2.id, status: "packaged")
      invoice4 = Invoice.create!(customer_id: bob.id, merchant_id: merchant2.id, status: "packaged")
      
      merchants_with_shipped = Merchant.item_status("shipped")
      merchants_with_packaged = Merchant.item_status("packaged")

      expect(merchants_with_shipped.length).to eq(1)
      expect(merchants_with_shipped).to include(merchant1)
      expect(merchants_with_packaged.length).to eq(1)
      expect(merchants_with_packaged).to include(merchant2)
    end

    it 'finds merchants by case insensitive name fragment and returns the first orderd alphabetically' do
      merchant1 = Merchant.create(name: "Apple")
      merchant2 = Merchant.create(name: "Bapple")
      merchant3 = Merchant.create(name: "Capple")
      merchant4 = Merchant.create(name: "Dapple")
      merchant5 = Merchant.create(name: "Eon")
      merchant6 = Merchant.create(name: "Fabulous")
      merchants = Merchant.all

      result1 = Merchant.filter_merchants(merchants, { name: "app" } )
      result2 = Merchant.filter_merchants(merchants, { name: "APP" } )
      result3 = Merchant.filter_merchants(merchants, { name: "apP" } )
      result4 = Merchant.filter_merchants(merchants, { name: "aPp" } )
      result5 = Merchant.filter_merchants(merchants, { name: "aPP" } )

      
      expect(result1.name).to eq("Apple")
      expect(result2.name).to eq("Apple")
      expect(result3.name).to eq("Apple")
      expect(result4.name).to eq("Apple")
      expect(result5.name).to eq("Apple")
    end

    it 'filters merchants based on name params' do
      result = Merchant.filter_merchants(Merchant.all, { name: "shop" })

      expect(result).to eq(@merchant2)
    end
  
    it 'filters merchants based on status params' do
      customer = Customer.create!(first_name: "Bob", last_name: "Tucker")
      invoice1 = Invoice.create!(customer_id: customer.id, merchant_id: @merchant1.id, status: "returned")
      invoice2 = Invoice.create!(customer_id: customer.id, merchant_id: @merchant2.id, status: "returned")
      invoice3 = Invoice.create!(customer_id: customer.id, merchant_id: @merchant1.id, status: "returned")
      invoice4 = Invoice.create!(customer_id: customer.id, merchant_id: @merchant3.id, status: "packaged")
  
      result = Merchant.filter_merchants(Merchant.all, { status: "returned" })
      expect(result).to eq([@merchant1, @merchant2])
      expect(result).not_to include(@merchant3)
    end  

    it 'renders an empty object if there are no merchants found' do
      result = Merchant.filter_merchants(Merchant.all, { name: "pumpkin" })
      # binding.pry

      expect(result).to eq({})
    end
  end
end