require 'spec_helper'

describe Note do
  describe "validations" do
    let(:note) { build(:note) }

    it "has a valid factory" do
      expect(note).to be_valid
    end

    it { should validate_presence_of :comments }

    it "ensures that the reminder status is valid" do
      note.reminder_status = 5
      expect(note).to be_invalid
    end

    it "should display a valid reminder status" do
      note.reminder_status = Note::NO_REMINDER
      expect(note.reminder_status_display).to eq('No Reminder')
      note.reminder_status = Note::SCHEDULED
      expect(note.reminder_status_display).to eq('Scheduled')
      note.reminder_status = Note::COMPLETED
      expect(note.reminder_status_display).to eq('Completed')
    end

    it "should expect recipients when scheduled date is present" do
      note.sched_time = 8.days.from_now
      expect(note).to be_invalid
    end
  end

  describe "associations" do
    it { should belong_to(:resource) }
    it { should belong_to(:author).class_name("User") }

    it { should have_many(:uploads).class_name("NoteUpload") }
    it { should accept_nested_attributes_for(:uploads).allow_destroy(true) }
    it { should accept_nested_attributes_for(:recipients).allow_destroy(true) }
  end

  describe "queries" do
    let(:user) { create(:user, email: 'someone@example.com') }
    let(:no_reminder_note) { create(:note, reminder_status: 0, recipients: [ ] ) }
    let(:scheduled_note) { create(:note, reminder_status: 1, recipients: [ NoteRecipient.new(user: user)] ) }
    let(:completed_note) { create(:note, reminder_status: 2, recipients: [ NoteRecipient.new(user: user)] ) }

    it "should find all the notes with no reminders" do
      expect(Note.no_reminder).to eq([no_reminder_note])
    end

    it "should find all the scheduled notes" do
      expect(Note.scheduled).to eq([scheduled_note])
    end

    it "should find all the completed notes" do
      expect(Note.completed).to eq([completed_note])
    end
  end

  describe "#self.send_reminders_for_tomorrow" do
    before do
      user1 = create(:user, email: 'someone1@example.com')
      user2 = create(:user, email: 'someone2@example.com')
      quote1 = create(:quote)
      quote2 = create(:quote)
      quote3 = create(:quote)
      create(:note, resource: quote1, sched_time: 1.day.from_now, 
                           reminder_status: Note::NO_REMINDER,
                           recipients: [ NoteRecipient.new(user: user1)])
      create(:note, resource: quote2, sched_time: 1.day.from_now, 
                           reminder_status: Note::SCHEDULED, 
                           recipients: [ NoteRecipient.new(user: user1)])
      create(:note, resource: quote3, sched_time: 1.day.from_now, 
                           reminder_status: Note::SCHEDULED, 
                           recipients: [ NoteRecipient.new(user: user2)])
    end

    it "should add email to delay queue" do
      expectedCount = Delayed::Job.count + 2
      Note.send_reminders_for_tomorrow
      expect(Delayed::Job.count).to eq expectedCount
    end
  end

  describe "#self.send_reminders_for_next_week" do
    before do
      user1 = create(:user, email: 'someone1@example.com')
      user2 = create(:user, email: 'someone2@example.com')
      quote1 = create(:quote)
      quote2 = create(:quote)
      quote3 = create(:quote)
      create(:note, resource: quote1, sched_time: 1.week.from_now, 
                           reminder_status: Note::NO_REMINDER,
                           recipients: [ NoteRecipient.new(user: user1)])
      create(:note, resource: quote2, sched_time: 1.week.from_now, 
                           reminder_status: Note::SCHEDULED, 
                           recipients: [ NoteRecipient.new(user: user1)])
      create(:note, resource: quote3, sched_time: 1.week.from_now, 
                           reminder_status: Note::SCHEDULED, 
                           recipients: [ NoteRecipient.new(user: user2)])
    end

    it "should add email to delay queue" do
      expectedCount = Delayed::Job.count + 2
      Note.send_reminders_for_next_week
      expect(Delayed::Job.count).to eq expectedCount
    end
  end

  describe "#complete_reminder_status" do
    before do
      user = create(:user, email: 'someone1@example.com')
      quote1 = create(:quote)
      quote2 = create(:quote)
      quote3 = create(:quote)
      create(:note, resource: quote1, sched_time: 1.day.ago, 
                           reminder_status: Note::NO_REMINDER,
                           recipients: [ NoteRecipient.new(user: user)])
      create(:note, resource: quote2, sched_time: 1.day.ago, 
                           reminder_status: Note::SCHEDULED, 
                           recipients: [ NoteRecipient.new(user: user)])
      create(:note, resource: quote3, sched_time: 1.day.ago, 
                           reminder_status: Note::SCHEDULED, 
                           recipients: [ NoteRecipient.new(user: user)])
    end

    it "should change reminder status to Completed the day after the note was due" do
      expect(Note.scheduled.count).to eq(2)
      Note.complete_reminder_status
      expect(Note.scheduled.count).to eq(0)
      expect(Note.completed.count).to eq(2)
    end
  end

end
