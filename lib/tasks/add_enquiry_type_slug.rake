namespace :enquiry_types do

  desc "Add slug to enquiry_types"
  task "add_enquiry_type_slug" => :environment do
    enq_type_names = ['Bus Enquiry', 'General Enquiry', 'Hire / Lease', 'ISUZU Enquiry',
                     'Mine Specification (Hire or Purchase)', 'Motorhome Enquiry', 'Sales Enquiry' ]
    slugs = ['bus', 'general', 'hire', 'isuzu', 'minespec', 'motorhome', 'sales']

    enq_type_names.each_with_index do |name, inx|
      enq_type = EnquiryType.find_by(name: name)
      if enq_type
        enq_type.slug = slugs[inx]
        enq_type.save!
        puts "Slug for #{name} is #{enq_type.slug}."
      end  
    end
  end
end