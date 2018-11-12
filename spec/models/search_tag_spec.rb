require 'spec_helper'

describe SearchTag do
  describe "validations" do
    let(:search_tag) { build(:search_tag)}

    it "has a valid factory" do
      expect(search_tag).to be_valid
    end

    it { should validate_presence_of :tag_type }
    it { should validate_presence_of :name }

    it "must be unique" do
      search_tag.save
      tag2 = search_tag.dup
      expect(tag2).to be_invalid
    end

    describe "#name" do
      before do
        @invalid_tags = ["", "abc", "b" * 21]
      end

      it "have the correct length" do
        @invalid_tags.each do |name|
          search_tag.name = name
          expect(search_tag).to be_invalid
        end
      end
    end

  end
end  