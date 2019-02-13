FactoryGirl.define do
  factory :document, class: Image do
    image_type Image::DOCUMENT
    document_type { DocumentType.first || create(:document_type) }
    photo_category nil
    imageable { Vehicle.first || create(:vehicle) }
    name "an official document"
    description "Description of my official document"
    image { File.open(Rails.root.join('spec', 'fixtures', 'images', 'delivery_sheet.pdf')) }
  end

  factory :photo, class: Image do
    image_type Image::PHOTO
    document_type nil
    photo_category { PhotoCategory.first || create(:photo_category) }
    imageable { Vehicle.first || create(:vehicle) }
    name "an illustrating photo"
    description "Description of my illustrating photo"
    image { File.open(Rails.root.join('spec', 'fixtures', 'images', 'commuter.jpg')) }
  end
end
