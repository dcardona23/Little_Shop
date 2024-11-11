require 'rails_helper'

RSpec.describe Coupon, type: :model do

  after(:all) do
    Coupon.delete_all
    Merchant.delete_all
  end

  before(:each) do 
    @merchant = Merchant.create!(name: "Test Merchant")
    @merchant1 = Merchant.create!(name: "Test Merchant2")

    bob = Customer.create!(first_name: "Bob", last_name: "Tucker")

    @item1 = Item.create({
      name: "apple",
      description: "is an apple",
      unit_price: 0.50,
      merchant_id: @merchant1.id
    })
    
    @item2 = Item.create({
      name: "cherry",
      description: "is a cherry",
      unit_price: 1.50,
      merchant_id: @merchant1.id
    })
    
    @item3 = Item.create({
      name: "pear",
      description: "is a pear",
      unit_price: 0.75,
      merchant_id: @merchant1.id
    })

    @coupon = Coupon.create!(
        name: "New Coupon", 
        code: "Test Code", 
        percent_off: 10,
        merchant_id: @merchant.id
      )

      @coupon1 = Coupon.create!(
      name: Faker::Commerce.product_name,
      code: Faker::Commerce.promotion_code,
      percent_off: 50,
      dollar_off: nil,
      merchant_id: @merchant.id, 
      active: false
    )

    @coupon2 = Coupon.create!(
      name: Faker::Commerce.product_name,
      code: Faker::Commerce.promotion_code,
      percent_off: 30,
      dollar_off: nil,
      merchant_id: @merchant.id, 
      active: true
    )

    @coupon3 = Coupon.create!(
      name: Faker::Commerce.product_name,
      code: Faker::Commerce.promotion_code,
      percent_off: 25,
      dollar_off: nil,
      merchant_id: @merchant1.id, 
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
      merchant_id: @merchant1.id, 
      active: true
    )

    @coupon6 = Coupon.create!(
      name: Faker::Commerce.product_name,
      code: Faker::Commerce.promotion_code,
      percent_off: nil,
      dollar_off: 2,
      merchant_id: @merchant1.id, 
      active: false
    )

    @invoice1 = Invoice.create!(
      customer_id: bob.id, 
      merchant_id: @merchant1.id, 
      status: "packaged", 
      )

    InvoiceItem.create!(
      invoice: @invoice1,
      item: @item1,
      quantity: 1, 
      unit_price: @item1.unit_price
    )

    @invoice1.update!(coupon_id: @coupon5.id)
    
  end

  describe 'relationships' do
    it { should belong_to :merchant }
    it { should have_many :invoices }
  end

  describe 'validations' do
    it {should validate_presence_of(:code)}

    it 'validates uniqueness of coupon code' do
      duplicate_coupon = Coupon.new(
        name: "Duplicate Coupon", 
        code: "Test Code", 
        percent_off: 15,
        merchant_id: @merchant.id
      )
      
      expect(duplicate_coupon).to be_invalid
    end

    it 'validates that either dollar_off or percent_off is present' do
      coupon7 = Coupon.new(
      name: Faker::Commerce.product_name,
      code: Faker::Commerce.promotion_code,
      percent_off: nil,
      dollar_off: nil,
      merchant_id: @merchant1.id, 
      active: true
    )

    expect(coupon7).not_to be_valid
    expect(coupon7.errors[:base]).to include("Either dollar_off or percent_off must be present")
    end

    it 'validates that both dollar_off and percent_off cannot be present' do
      coupon8 = Coupon.new(percent_off: 10, dollar_off: 10)

      coupon8.only_one_discount_present

      expect(coupon8).not_to be_valid
      expect(coupon8.errors[:base]).to include("Cannot have both dollar_off and percent_off")
    end

    it 'validates any combination of dollar_off and percent_off' do
      coupon_with_dollar_off = Coupon.new(
        name: Faker::Commerce.product_name,
        code: Faker::Commerce.promotion_code,
        percent_off: nil,
        dollar_off: 10,
        merchant_id: @merchant1.id, 
        active: true
      )
      
      coupon_with_percent_off = Coupon.new(
        name: Faker::Commerce.product_name,
        code: Faker::Commerce.promotion_code,
        percent_off: nil,
        dollar_off: 10,
        merchant_id: @merchant1.id, 
        active: true
      ) 

      invalid_coupon1 = Coupon.new

      invalid_coupon2 = Coupon.new(
        name: Faker::Commerce.product_name,
        code: Faker::Commerce.promotion_code,
        percent_off: nil,
        dollar_off: nil,
        merchant_id: @merchant1.id, 
        active: true
      )

      expect(coupon_with_dollar_off).to be_valid
      expect(coupon_with_percent_off).to be_valid
      expect(invalid_coupon1).not_to be_valid
      expect(invalid_coupon2).not_to be_valid
    end

    it 'requires a coupon to have either dollar_off or percent_off' do
      coupon7 = Coupon.new(
      name: Faker::Commerce.product_name,
      code: Faker::Commerce.promotion_code,
      percent_off: nil,
      dollar_off: nil,
      merchant_id: @merchant1.id, 
      active: true
      )
  
      coupon7.dollar_off_or_percent_off_present
      @coupon2.dollar_off_or_percent_off_present
      @coupon4.dollar_off_or_percent_off_present
  # binding.pry
      expect(coupon7).not_to be_valid
      expect(coupon7.errors[:base]).to include("Either dollar_off or percent_off must be present")
      expect(@coupon2.errors[:base]).to be_empty
      expect(@coupon4.errors[:base]).to be_empty
    end
  end

  describe 'filtering coupons' do
    it 'filters coupons based on merchant_id' do
      result = Coupon.filter_coupons(Coupon.all, { merchant_id: @merchant.id })
      expect(result).to eq([@coupon, @coupon1, @coupon2])
      expect(result).not_to include(@coupon3, @coupon4, @coupon5)
    end

    it 'filters coupons based on active status' do
      result = Coupon.filter_coupons(Coupon.all, { merchant_id: @merchant.id, active: true })
      expect(result).to eq([@coupon2])
      expect(result).not_to include(@coupon1, @coupon3, @coupon4, @coupon5)
    end
  end

  describe 'activating coupons' do
    it 'will activate a coupon' do
      
      expect(@coupon1.activate(@merchant.id)).to be true
    end

    it 'will not activate a coupon that is already active' do

      expect(@coupon2.activate(@merchant.id)).to be false
      expect(@coupon2.errors.full_messages).to include("Coupon is already active")
    end

    it 'will not activate a coupon for a merchant that has 5 active coupons' do
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

    expect(@coupon6.activate(@merchant1.id)).to be false
    expect(@coupon6.errors.full_messages).to include("Merchant cannot have more than 5 active coupons")
    end
  end

  describe 'deactivation' do
    it 'can deactivate a coupon' do

      expect(@coupon2.deactivate).to be true
    end

    it 'will not deactivate a coupon that is already inactive' do

      expect(@coupon6.deactivate).to be false
      expect(@coupon6.errors.full_messages).to include("Coupon is already inactive")
    end

    it 'cannot deactivate a coupon with pending invoices' do
      
      expect(@coupon5.deactivate).to be false
      expect(@coupon5.errors.full_messages).to include("Coupon cannot be deactivated with pending invoices")
    end
  end
end