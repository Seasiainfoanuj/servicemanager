class WorkorderType < ActiveRecord::Base

  has_many :workorders
  has_many :workorder_type_uploads, :dependent => :destroy

end
