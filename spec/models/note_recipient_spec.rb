require 'spec_helper'

describe NoteRecipient do
  describe "validations" do
    let(:user)   { create(:user) }
    let(:note)   { create(:note) }
    let(:note_2) { create(:note) }

    it "has a valid factory" do
      expect(build(:note_recipient, user: user)).to be_valid
    end

    it "should not allow a note to contain duplicate users" do
      recipient_A = create(:note_recipient, user: user, note: note)
      recipient_B = recipient_A.dup
      expect(recipient_B).not_to be_valid
    end

  end

  describe "associations" do
    it { should belong_to(:note) }
  end
end