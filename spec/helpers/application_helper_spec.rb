require 'spec_helper'

describe ApplicationHelper do
  describe "#display_date" do
    before do
      @test_date = Date.new(2016,01,31)
    end

    it "returns the appropriate date format" do
      expect(display_date(@test_date)).to eq('31 January 2016')
      expect(display_date(@test_date, {format: :short})).to eq('31/01/2016')
      expect(display_date(@test_date, {format: :month})).to eq('January 2016')
    end
  end
end