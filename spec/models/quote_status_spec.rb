require 'spec_helper'

describe QuoteStatus do
  describe "Status lookups" do
    it "should give the title for a given quote status" do
      expect(QuoteStatus.display_status('changes requested')).to eq('Changes Requested')
    end
  end

  describe "New status after Quote action is performed" do
    it "should not suggest a status change after sending an accepted quoted" do
      expect(QuoteStatus.status_after_action(:send_quote, 'accepted')).to eq('accepted')
    end

    it "should suggest that after sending a 'viewed' quote, its status changes to 'sent'" do
      expect(QuoteStatus.status_after_action(:send_quote, 'viewed')).to eq('sent')
    end

    it "should suggest that after viewing a 'draft' quote, its status changes to 'viewed'" do
      expect(QuoteStatus.status_after_action(:show, 'draft')).to eq('viewed')
    end

    it "should suggest that after requesting a change to an 'accepted' quote, its status becomes 'changes requested'" do
      expect(QuoteStatus.status_after_action(:request_change, 'accepted')).to eq('changes requested')
    end

    it "should suggest that after viewing an accepted quote, its status does not change" do
      expect(QuoteStatus.status_after_action(:show, 'accepted')).to eq('accepted')
    end

    it "should raise an exception when 'status_after_action' has an invalid action parameter" do
      expect { QuoteStatus.status_after_action(:dont_do_it, 'draft') }.to raise_error("Invalid Action")
    end

    it "should raise an exception when 'status_after_action' has an incorrectly formatted action parameter" do
      expect { QuoteStatus.status_after_action('show', 'draft') }.to raise_error("Invalid Action Format")
    end

    it "should raise an exception when 'status_after_action' has an invalid status parameter" do
      expect { QuoteStatus.status_after_action(:send_quote, 'unexpected') }.to raise_error("Invalid Status")
    end

    it "should raise an exception when 'status_after_action' has an incorrectly formatted status parameter" do
      expect { QuoteStatus.status_after_action(:show, :draft) }.to raise_error("Invalid Status Format")
    end
  end

  describe "Get permission to perform an action on a quote with a given status" do
    it "should not advise that an accepted quote can be updated" do
      expect(QuoteStatus.action_permitted?(:update, 'accepted')).to be(false)
    end

    it "should advise that a cancelled quote can be updated" do
      expect(QuoteStatus.action_permitted?(:update, 'cancelled')).to be(false)
    end

    it "should advise that a quote can be sent regardless of its status" do
      expect(QuoteStatus.action_permitted?(:send_quote, 'accepted')).to be(true)
    end
  end
end