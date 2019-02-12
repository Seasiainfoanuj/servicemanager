module IsValidAbn
  extend ActiveSupport::Concern
  included do
    def is_valid_abn?
      weights = [10, 1, 3, 5, 7, 9, 11, 13, 15, 17, 19]
      # strip anything other than digits
      abn = self.abn.gsub(/\D/, '')
      
      unless abn.length == 11
        errors.add(:abn, "ABN is invalid - must have 11 digits.")
        return
      end
      sum = 0
      (0..10).each do |i|
        c = abn[i,1]
        digit = c.to_i - (i.zero? ? 1 : 0)
        sum += weights[i] * digit
      end
      unless sum % 89 == 0
        errors.add(:abn, "ABN is invalid - failed weighting validation.")
      end
    end
  end
end
