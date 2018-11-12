namespace :hire_agreements do

  desc "Add invoice companies to existing hire_agreements"
  task "add_invoice_company" => :environment do
    hire_agreement_count = 0
    invoice_company = InvoiceCompany.find_by(name: "BUS 4x4 Hire Pty. Ltd.")
    hire_agreement_type = HireAgreementType.find_by(name: "Default type")
    HireAgreement.all.each do |ha|
      ha.invoice_company = invoice_company
      ha.type = hire_agreement_type if ha.type.nil?
      ha.save!
      hire_agreement_count += 1
    end
    puts "Total HireAgreements modified: #{hire_agreement_count}"
  end
end