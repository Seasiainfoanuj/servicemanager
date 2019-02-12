WorkorderType.delete_all

WorkorderType.create(name: "architecto", label_color: "#ec8097", 
  notes: ["Explicabo nulla reiciendis hic totam debitis. Molestiae aut maxime animi. Nobis aut fuga. Exercitationem officiis ut aut. Ut omnis sed id facilis voluptatem quam.", 
          "Magni quis aliquid. Veritatis minus sed. Corporis dolore et mollitia est. Repellendus inventore qui est cumque. Ea voluptatem sequi consequuntur natus animi veritatis est.", 
          "Et modi consequatur officia reiciendis illum. Facere velit eligendi deleniti. Quia qui autem nulla aut cupiditate sit."])
WorkorderType.create(name: "eius", label_color: "#f46e0d", 
  notes: ["Qui corporis enim voluptates. Minima doloribus quos qui voluptas dolor et ea. Earum eos eius.", 
          "Vero officia architecto quis. Quam est voluptatibus nemo nihil officiis. Sed officia dolorum et suscipit. Quisquam est mollitia laboriosam.", 
          "Rem repellat libero rerum et. Blanditiis dolorum autem quo assumenda. Veritatis mollitia incidunt consequatur qui nihil esse. Voluptatum deleniti mollitia non qui reprehenderit."])

puts "#{WorkorderType.count} WorkorderTypes loaded"
vehicles = Vehicle.all
Workorder.create(vehicle_id: vehicles[0].id, workorder_type_id: WorkorderType.first.id, 
  uid: "WO-TF2984", status: "confirmed", is_recurring: false, recurring_period: nil, 
  service_provider_id: User.service_provider.first.id, customer_id: User.customer.first.id, 
  manager_id: User.admin.last.id, sched_time: "2016-12-09 23:00:00", etc: "2017-01-03 23:00:00", 
  details: "<p>2 x struts 1500 nm 1100mm long</p>\r\n\r\n<p>2 x bal...", 
  invoice_company_id: InvoiceCompany.first.id)

Workorder.create(vehicle_id: vehicles[1].id, workorder_type_id: WorkorderType.last.id, 
  uid: "WO-BQ8563", status: "confirmed", is_recurring: false, recurring_period: nil, 
  service_provider_id: User.service_provider[0].id, customer_id: User.customer.last.id, 
  manager_id: User.admin.last.id, sched_time: "2015-03-11 23:00:00", etc: "2015-03-11 23:00:00", 
  details: "<p>exhaust pipe fitting</p>\r\n", invoice_company_id: 1)