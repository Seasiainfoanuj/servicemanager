class NoteRecipient < ActiveRecord::Base

  belongs_to :note
  belongs_to :user

  validates :user_id, presence: true,
                    uniqueness: { scope: :note,
                    message: "duplicate recipients not allowed for note" }

end