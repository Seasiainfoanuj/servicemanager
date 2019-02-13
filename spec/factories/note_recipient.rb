FactoryGirl.define do
  factory :note_recipient do
    association :note, factory: :note
    association :user, factory: :user
  end
end

