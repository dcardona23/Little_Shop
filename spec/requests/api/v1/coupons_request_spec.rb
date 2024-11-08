require 'rails_helper'

describe "coupons" do
  before(:each) do

    @merchant1 = Merchant.create!(
      name: "Susan"
    )
    @merchant2 = Merchant.create!(
      name: "Steve"
    )

    @coupon1 = Coupon.create!(
      name: Faker::Commerce.product_name,
      code: Faker::Commerce.promotion_code,
      percent_off: 50,
      dollar_off: nil,
      merchant_id: @merchant1.id, 
      active: true
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
  end

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

end