class JobSubscriber < ActiveRecord::Base
  belongs_to :user
  belongs_to :job, :polymorphic => true
  belongs_to :workorder, :class_name => "Workorder",
                         :foreign_key => "job_id"
  belongs_to :build_order, :class_name => "BuildOrder",
                           :foreign_key => "job_id"
  belongs_to :off_hire_job, :class_name => "OffHireJob",
                            :foreign_key => "job_id"
end
