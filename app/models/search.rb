class Search
  include ActiveModel::Model

  attr_accessor :view_type, :rego, :vin, :bus_num, :call_sign, :date_from, :date_until

end