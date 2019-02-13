namespace :invoice_companies do

  desc "Add slug to invoice companies"
  task "add_invoice_company_slug" => :environment do
    company_names = ['4x4 Motorhomes Australia', 'BUS 4x4 Hire Pty. Ltd.', 'Bus 4x4 Holdings Pty Ltd',
                     'BUS 4x4 Pty Ltd', 'I-BUS Australia Pty Ltd', 'Universal Vehicle Sales Pty Ltd' ]
    slugs = ['motorhomes', 'bus_hire', 'bus4x4holdings', 'bus4x4', 'ibus', 'universal_veh_sales']

    company_names.each_with_index do |name, inx|
      company = InvoiceCompany.find_by(name: name)
      if company
        company.slug = slugs[inx]
        company.country = 'Australia' if company.country.blank?
        company.save!
        puts "Slug for #{name} is #{company.slug}."
      end  
    end
  end
end
