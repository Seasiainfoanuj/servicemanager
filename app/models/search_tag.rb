class SearchTag < ActiveRecord::Base

  TAG_TYPES = ['hire_quote', 'vehicle', 'vehicle_model']

  before_save :prepare_tag_names

  validates :tag_type, presence: true,
                   inclusion: { in: TAG_TYPES }
  validates :name, presence: true,
                   uniqueness: { scope: :tag_type },
                   length: { minimum: 4, maximum: 20 }

  default_scope { order("tag_type ASC, name ASC") }

  scope :hire_quote, -> { SearchTag.where(tag_type: 'hire_quote') }
  scope :vehicle, -> { SearchTag.where(tag_type: 'vehicle') }
  scope :vehicle_model, -> { SearchTag.where(tag_type: 'vehicle_model') }

  def self.update_tag_list(tag_type, candidate_tags)
    return unless candidate_tags
    tags = candidate_tags.split(',')
    tags.each do |tag|
      candidate = tag.strip.downcase
      unless SearchTag.exists?(tag_type: tag_type, name: candidate)
        tag = SearchTag.new(tag_type: tag_type, name: candidate)
        return false unless tag.valid?
        tag.save
      end  
    end
    true
  end

  private

    def prepare_tag_names
      self.name = name.strip.downcase
    end

end