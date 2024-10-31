require 'rails_helper'

RSpec.describe Merchant do

  before(:each) do
    merchant1 = Merchant.create(name: "Little Shop of Horrors")
    merchant2 = Merchant.create(name: "Large Shop of Wonders")
    merchant3 = Merchant.create(name: "Wizard's Chest")
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

    

  end
end