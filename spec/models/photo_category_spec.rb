require 'spec_helper'

describe PhotoCategory do
  describe "validations" do

    let(:photo_category) { build(:photo_category)}

    it "has a valid factory" do
      expect(photo_category).to be_valid
    end

    it "must have a name" do
      photo_category.name = ""
      expect(photo_category).to be_invalid
    end

    it "must have a unique name" do
      photo_category.save!
      cat2 = photo_category.dup
      expect { cat2.save! }.to raise_error
    end

  end
end