require 'rails_helper'

describe "coupons" do
  before(:each) do

    @merchant1 = Merchant.create!(
      name: "Susan"
    )
    @merchant2 = Merchant.create!(
      name: "Steve"
    )

    @item1 = Item.create({
      name: "apple",
      description: "is an apple",
      unit_price: 0.50,
      merchant_id: @merchant1.id
    })

    @coupon1 = Coupon.create!(
      name: Faker::Commerce.product_name,
      code: Faker::Commerce.promotion_code,
      percent_off: 50,
      dollar_off: nil,
      merchant_id: @merchant1.id, 
      active: false
    )

    @coupon2 = Coupon.create!(
      name: Faker::Commerce.product_name,
      code: Faker::Commerce.promotion_code,
      percent_off: 30,
      dollar_off: nil,
      merchant_id: @merchant1.id, 
      active: true
    )

    @coupon3 = Coupon.create!(
      name: Faker::Commerce.product_name,
      code: Faker::Commerce.promotion_code,
      percent_off: 25,
      dollar_off: nil,
      merchant_id: @merchant2.id, 
      active: true
    )

    @coupon4 = Coupon.create!(
      name: Faker::Commerce.product_name,
      code: Faker::Commerce.promotion_code,
      percent_off: nil,
      dollar_off: 5,
      merchant_id: @merchant1.id, 
      active: true
    )

    @coupon5 = Coupon.create!(
      name: Faker::Commerce.product_name,
      code: Faker::Commerce.promotion_code,
      percent_off: nil,
      dollar_off: 2,
      merchant_id: @merchant2.id, 
      active: true
    )

    bob = Customer.create!(
      first_name: "Bob", last_name: "Tucker"
    )

    invoice1 = Invoice.create!(
      customer_id: bob.id, merchant_id: @merchant1.id, status: "packaged"
    )

    InvoiceItem.create!(
      invoice: invoice1,
      item: @item1,
      quantity: 1, 
      unit_price: @item1.unit_price
    )

    invoice1.update!(coupon_id: @coupon4.id)

  end

  describe 'getting coupons' do
    it 'can get all coupons for a specified merchant' do
      get "/api/v1/merchants/#{@merchant1.id}/coupons"
      coupons = JSON.parse(response.body, symbolize_names: true)

      expect(response).to be_successful
      expect(coupons[:data].length).to eq(3)
      expect(coupons[:data][0][:attributes][:name]).to eq(@coupon1.name)
      expect(coupons[:data][1][:attributes][:name]).to eq(@coupon2.name)
      expect(coupons[:data][2][:attributes][:name]).to eq(@coupon4.name)
    end

    it 'can get all coupons for a different merchant' do
      get "/api/v1/merchants/#{@merchant2.id}/coupons"
      coupons = JSON.parse(response.body, symbolize_names: true)

      expect(response).to be_successful
      expect(coupons[:data].length).to eq(2)
      expect(coupons[:data][0][:attributes][:name]).to eq(@coupon3.name)
      expect(coupons[:data][1][:attributes][:name]).to eq(@coupon5.name)
    end

    it 'can get a single coupon by id' do
      get "/api/v1/coupons/#{@coupon1.id}"
      coupons = JSON.parse(response.body, symbolize_names: true)

      expect(response).to be_successful
      expect(coupons[:data][:attributes][:name]).to eq(@coupon1.name)
    end

    it 'can get all of a merchant/s active coupons' do
      get "/api/v1/merchants/#{@merchant1.id}/coupons?active=true"
      coupons = JSON.parse(response.body, symbolize_names: true)

      expect(response).to be_successful
      expect(coupons[:data].length).to eq(2)
      expect(coupons[:data][0][:attributes][:name]).to eq(@coupon2.name)
      expect(coupons[:data][1][:attributes][:name]).to eq(@coupon4.name)
    end

    it 'can get all of a merchant/s inactive coupons' do
      get "/api/v1/merchants/#{@merchant1.id}/coupons?active=false"
      coupons = JSON.parse(response.body, symbolize_names: true)

      expect(response).to be_successful
      expect(coupons[:data].length).to eq(1)
      expect(coupons[:data][0][:attributes][:name]).to eq(@coupon1.name)
    end

  end

  describe 'creating coupons' do
    it 'can create a new coupon' do
      coupon_params = {
        name: Faker::Commerce.product_name,
        code: Faker::Commerce.promotion_code,
        percent_off: 50,
        dollar_off: nil,
        merchant_id: @merchant1.id
        }

      headers = {"CONTENT_TYPE" => "application/json"}
      post "/api/v1/coupons", headers: headers, params: JSON.generate(coupon: coupon_params)

      new_coupon = Coupon.last

      expect(response).to be_successful
      expect(new_coupon.name).to eq(coupon_params[:name])
    end

    it 'cannot create a coupon with a duplicate coupon code' do
      coupon = Coupon.create!(
        name: Faker::Commerce.product_name,
        code: "FreeToday",
        percent_off: nil,
        dollar_off: 2,
        merchant_id: @merchant2.id, 
        active: true
      )

      coupon_params = {
        name: Faker::Commerce.product_name,
        code: "FreeToday",
        percent_off: 50,
        dollar_off: nil,
        merchant_id: @merchant1.id
        }

      headers = {"CONTENT_TYPE" => "application/json"}
      post "/api/v1/coupons", headers: headers, params: JSON.generate(coupon: coupon_params)
      data = JSON.parse(response.body, symbolize_names: true)


      expect(response).not_to be_successful
      expect(response).to have_http_status(422)      
      expect(data[:message]).to eq("Your query could not be completed")
      expect(data[:errors]).to be_an(Array)
      expect(data[:errors][0]).to eq("Code has already been used")
    end

    it 'cannot create a coupon without either dollar_off or percent_off' do
      coupon_params = {
        name: Faker::Commerce.product_name,
        code: "FreeToday",
        percent_off: nil,
        dollar_off: nil,
        merchant_id: @merchant1.id
        }

      headers = {"CONTENT_TYPE" => "application/json"}
      post "/api/v1/coupons", headers: headers, params: JSON.generate(coupon: coupon_params)
      data = JSON.parse(response.body, symbolize_names: true)

      expect(response).not_to be_successful
      expect(response).to have_http_status(422)      
      expect(data[:message]).to eq("Your query could not be completed")
      expect(data[:errors]).to be_an(Array)
      expect(data[:errors][0]).to eq("Either dollar_off or percent_off must be present")
    end

    it 'cannot create a coupon with both dollar_off and percent_off' do
      coupon_params = {
        name: Faker::Commerce.product_name,
        code: "FreeToday",
        percent_off: 20,
        dollar_off: 20,
        merchant_id: @merchant1.id
        }

      headers = {"CONTENT_TYPE" => "application/json"}
      post "/api/v1/coupons", headers: headers, params: JSON.generate(coupon: coupon_params)
      data = JSON.parse(response.body, symbolize_names: true)

      expect(response).not_to be_successful
      expect(response).to have_http_status(422)      
      expect(data[:message]).to eq("Your query could not be completed")
      expect(data[:errors]).to be_an(Array)
      expect(data[:errors][0]).to eq("Cannot have both dollar_off and percent_off")
    end

    it 'cannot save a coupon if the merchant has 5 active coupons' do
      @coupon6 = Coupon.create!(
      name: Faker::Commerce.product_name,
      code: Faker::Commerce.promotion_code,
      percent_off: nil,
      dollar_off: 2,
      merchant_id: @merchant1.id, 
      active: true
      )

      @coupon7 = Coupon.create!(
      name: Faker::Commerce.product_name,
      code: Faker::Commerce.promotion_code,
      percent_off: nil,
      dollar_off: 2,
      merchant_id: @merchant1.id, 
      active: true
      )

      @coupon8 = Coupon.create!(
      name: Faker::Commerce.product_name,
      code: Faker::Commerce.promotion_code,
      percent_off: nil,
      dollar_off: 2,
      merchant_id: @merchant1.id, 
      active: true
      )

      coupon_params = {
        name: Faker::Commerce.product_name,
        code: "FreeToday",
        percent_off: 20,
        dollar_off: nil,
        merchant_id: @merchant1.id
        }

      headers = {"CONTENT_TYPE" => "application/json"}
      post "/api/v1/coupons", headers: headers, params: JSON.generate(coupon: coupon_params)
      data = JSON.parse(response.body, symbolize_names: true)

        # binding.pry
      expect(response).not_to be_successful
      expect(response).to have_http_status(422)      
      expect(data[:message]).to eq("Your query could not be completed")
      expect(data[:errors]).to be_an(Array)
      expect(data[:errors][0]).to eq("Merchant cannot have more than 5 active coupons")
    end
  end

  describe 'activating coupons' do 
    it 'can activate a coupon' do
      expect(@coupon1.active).to eq(false)

      patch activate_api_v1_coupon_path(@coupon1), headers: headers

      expect(response).to be_successful
      @coupon1.reload
      expect(@coupon1.active).to eq(true)
    end

    it 'can activate up to five coupons for a merchant' do
      coupon6 = Coupon.create!(
        name: Faker::Commerce.product_name,
        code: Faker::Commerce.promotion_code,
        percent_off: nil,
        dollar_off: 2,
        merchant_id: @merchant1.id, 
        active: true
      )

      coupon7 = Coupon.create!(
        name: Faker::Commerce.product_name,
        code: Faker::Commerce.promotion_code,
        percent_off: nil,
        dollar_off: 2,
        merchant_id: @merchant1.id, 
        active: true
      )
      
      patch activate_api_v1_coupon_path(@coupon1), headers: headers

      expect(response).to be_successful
      @coupon1.reload
      expect(@coupon1.active).to eq(true)
    end

    it 'cannot activate a coupon if a merchant has five active coupons' do
      expect(@coupon1.active).to eq(false)

      coupon6 = Coupon.create!(
        name: Faker::Commerce.product_name,
        code: Faker::Commerce.promotion_code,
        percent_off: nil,
        dollar_off: 2,
        merchant_id: @merchant1.id, 
        active: true
      )

      coupon7 = Coupon.create!(
        name: Faker::Commerce.product_name,
        code: Faker::Commerce.promotion_code,
        percent_off: nil,
        dollar_off: 2,
        merchant_id: @merchant1.id, 
        active: true
      )

      coupon8 = Coupon.create!(
        name: Faker::Commerce.product_name,
        code: Faker::Commerce.promotion_code,
        percent_off: nil,
        dollar_off: 2,
        merchant_id: @merchant1.id, 
        active: true
      )

      patch activate_api_v1_coupon_path(@coupon1), headers: headers

      expect(response).not_to be_successful
      @coupon1.reload
      expect(@coupon1.active).to eq(false)
    end

    it 'will not activate a coupon if it is already active' do
      expect(@coupon2.active).to eq(true)
      patch activate_api_v1_coupon_path(@coupon2), headers: headers

      expect(response).to have_http_status(400)
        
      data = JSON.parse(response.body, symbolize_names: true)

      expect(data[:message]).to eq("Your query could not be completed")
      expect(data[:errors]).to be_an(Array)
      expect(data[:errors][0]).to eq("Coupon is already active")
    end

  end

  describe 'deactivating coupons' do 
    it 'can deactivate a coupon' do
      patch deactivate_api_v1_coupon_path(@coupon3), headers: headers

      expect(response).to be_successful
      @coupon3.reload
      expect(@coupon3.active).to eq(false)
    end

    it 'will not deactivate a coupon if it is already inactive' do
      expect(@coupon1.active).to eq(false)
      patch deactivate_api_v1_coupon_path(@coupon1), headers: headers

      expect(response).to have_http_status(400)
        
      data = JSON.parse(response.body, symbolize_names: true)
      
      expect(data[:message]).to eq("Your query could not be completed")
      expect(data[:errors]).to be_an(Array)
      expect(data[:errors][0]).to eq("Coupon is already inactive")
    end

    it 'will not deactivate a coupon with pending invoices' do
      patch deactivate_api_v1_coupon_path(@coupon4), headers: headers

      expect(response).to have_http_status(400)
        
      data = JSON.parse(response.body, symbolize_names: true)
      
      expect(data[:message]).to eq("Your query could not be completed")
      expect(data[:errors]).to be_an(Array)
      expect(data[:errors][0]).to eq("Coupon cannot be deactivated with pending invoices")
    end
  end
end