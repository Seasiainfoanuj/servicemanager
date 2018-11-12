require 'spec_helper'

describe DocumentType do
  describe "validations" do

    let(:document_type) { build(:document_type)}

    it "has a valid factory" do
      expect(document_type).to be_valid
    end

    it "must have a name" do
      document_type.name = ""
      expect(document_type).to be_invalid
    end

    it "must have a label_color" do
      document_type.label_color = ""
      expect(document_type).to be_invalid
    end

    it "must have a unique name" do
      document_type.save!
      doc2 = document_type.dup
      expect { doc2.save! }.to raise_error
    end

  end
end
