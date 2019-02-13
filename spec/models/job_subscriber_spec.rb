require 'spec_helper'

describe JobSubscriber do
  describe "associations" do
    it { should belong_to(:user) }
    it { should belong_to(:job) }
    it { should belong_to(:workorder).class_name('Workorder').with_foreign_key('job_id') }
    it { should belong_to(:build_order).class_name('BuildOrder').with_foreign_key('job_id') }
    it { should belong_to(:off_hire_job).class_name('OffHireJob').with_foreign_key('job_id') }
  end
end
