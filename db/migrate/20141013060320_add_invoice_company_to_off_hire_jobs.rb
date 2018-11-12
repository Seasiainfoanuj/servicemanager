class AddInvoiceCompanyToOffHireJobs < ActiveRecord::Migration
  def change
    add_reference :off_hire_jobs, :invoice_company, index: true
  end
end
