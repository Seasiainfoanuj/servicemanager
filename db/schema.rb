# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20180105124644) do

  create_table "activities", force: :cascade do |t|
    t.integer  "trackable_id",   limit: 4
    t.string   "trackable_type", limit: 255
    t.integer  "owner_id",       limit: 4
    t.string   "owner_type",     limit: 255
    t.string   "key",            limit: 255
    t.text     "parameters",     limit: 65535
    t.integer  "recipient_id",   limit: 4
    t.string   "recipient_type", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "activities", ["owner_id", "owner_type"], name: "index_activities_on_owner_id_and_owner_type", using: :btree
  add_index "activities", ["recipient_id", "recipient_type"], name: "index_activities_on_recipient_id_and_recipient_type", using: :btree
  add_index "activities", ["trackable_id", "trackable_type"], name: "index_activities_on_trackable_id_and_trackable_type", using: :btree

  create_table "addresses", force: :cascade do |t|
    t.integer  "user_id",          limit: 4
    t.string   "line_1",           limit: 255
    t.string   "line_2",           limit: 255
    t.string   "suburb",           limit: 255
    t.string   "state",            limit: 255
    t.string   "postcode",         limit: 255
    t.string   "country",          limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "enquiry_id",       limit: 4
    t.integer  "address_type",     limit: 4,   default: 0
    t.integer  "addressable_id",   limit: 4
    t.string   "addressable_type", limit: 255
  end

  add_index "addresses", ["enquiry_id"], name: "index_addresses_on_enquiry_id", using: :btree
  add_index "addresses", ["user_id"], name: "index_addresses_on_user_id", using: :btree

  create_table "build_order_uploads", force: :cascade do |t|
    t.integer  "build_order_id",      limit: 4
    t.string   "upload_file_name",    limit: 255
    t.string   "upload_content_type", limit: 255
    t.integer  "upload_file_size",    limit: 4
    t.datetime "upload_updated_at"
  end

  add_index "build_order_uploads", ["build_order_id"], name: "index_build_order_uploads_on_build_order_id", using: :btree

  create_table "build_orders", force: :cascade do |t|
    t.integer  "build_id",               limit: 4
    t.integer  "service_provider_id",    limit: 4
    t.integer  "manager_id",             limit: 4
    t.string   "name",                   limit: 255
    t.string   "uid",                    limit: 25
    t.string   "status",                 limit: 25
    t.datetime "sched_time"
    t.datetime "etc"
    t.text     "details",                limit: 65535
    t.text     "service_provider_notes", limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "invoice_company_id",     limit: 4
  end

  add_index "build_orders", ["build_id"], name: "index_build_orders_on_build_id", using: :btree
  add_index "build_orders", ["invoice_company_id"], name: "index_build_orders_on_invoice_company_id", using: :btree
  add_index "build_orders", ["manager_id"], name: "index_build_orders_on_manager_id", using: :btree
  add_index "build_orders", ["service_provider_id"], name: "index_build_orders_on_service_provider_id", using: :btree

  create_table "build_specifications", force: :cascade do |t|
    t.integer  "build_id",             limit: 4
    t.integer  "swing_type",           limit: 4,     default: 0
    t.integer  "heating_source",       limit: 4,     default: 0
    t.integer  "total_seat_count",     limit: 4,     default: 0
    t.integer  "seating_type",         limit: 4,     default: 0
    t.integer  "state_sign",           limit: 4,     default: 0
    t.text     "paint",                limit: 65535
    t.text     "other_seating",        limit: 65535
    t.text     "surveillance_system",  limit: 65535
    t.text     "comments",             limit: 65535
    t.boolean  "lift_up_wheel_arches",               default: false
    t.datetime "created_at",                                         null: false
    t.datetime "updated_at",                                         null: false
  end

  add_index "build_specifications", ["build_id"], name: "index_build_specifications_on_build_id", using: :btree

  create_table "build_uploads", force: :cascade do |t|
    t.integer  "build_id",            limit: 4
    t.string   "upload_file_name",    limit: 255
    t.string   "upload_content_type", limit: 255
    t.integer  "upload_file_size",    limit: 4
    t.datetime "upload_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "build_uploads", ["build_id"], name: "index_build_uploads_on_build_id", using: :btree

  create_table "builds", force: :cascade do |t|
    t.integer  "vehicle_id",         limit: 4
    t.integer  "manager_id",         limit: 4
    t.integer  "quote_id",           limit: 4
    t.string   "number",             limit: 25
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "invoice_company_id", limit: 4
  end

  add_index "builds", ["invoice_company_id"], name: "index_builds_on_invoice_company_id", using: :btree
  add_index "builds", ["manager_id"], name: "index_builds_on_manager_id", using: :btree
  add_index "builds", ["quote_id"], name: "index_builds_on_quote_id", using: :btree
  add_index "builds", ["vehicle_id"], name: "index_builds_on_vehicle_id", using: :btree

  create_table "clients", force: :cascade do |t|
    t.string   "reference_number", limit: 255
    t.string   "client_type",      limit: 255
    t.integer  "user_id",          limit: 4
    t.integer  "company_id",       limit: 4
    t.datetime "archived_at"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  add_index "clients", ["company_id"], name: "index_clients_on_company_id", using: :btree
  add_index "clients", ["reference_number"], name: "index_clients_on_reference_number", using: :btree
  add_index "clients", ["user_id"], name: "index_clients_on_user_id", using: :btree

  create_table "companies", force: :cascade do |t|
    t.string   "name",               limit: 255, null: false
    t.string   "trading_name",       limit: 255
    t.string   "website",            limit: 255
    t.string   "abn",                limit: 255
    t.string   "vendor_number",      limit: 255
    t.datetime "archived_at"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.integer  "default_contact_id", limit: 4
  end

  add_index "companies", ["name"], name: "index_companies_on_name", using: :btree

  create_table "contact_role_types", force: :cascade do |t|
    t.string "name", limit: 255
  end

  create_table "contacts_roles", id: false, force: :cascade do |t|
    t.integer "user_id",              limit: 4
    t.integer "contact_role_type_id", limit: 4
  end

  add_index "contacts_roles", ["contact_role_type_id"], name: "index_contacts_roles_on_contact_role_type_id", using: :btree
  add_index "contacts_roles", ["user_id", "contact_role_type_id"], name: "index_contacts_roles_on_user_id_and_contact_role_type_id", unique: true, using: :btree
  add_index "contacts_roles", ["user_id"], name: "index_contacts_roles_on_user_id", using: :btree

  create_table "cover_letters", force: :cascade do |t|
    t.integer  "covering_subject_id",   limit: 4
    t.string   "covering_subject_type", limit: 255
    t.string   "title",                 limit: 255
    t.text     "content",               limit: 65535
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  create_table "customer_memberships", force: :cascade do |t|
    t.integer  "quoted_by_company_id", limit: 4
    t.integer  "quoted_customer_id",   limit: 4
    t.string   "xero_identifier",      limit: 255
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
  end

  add_index "customer_memberships", ["quoted_customer_id"], name: "index_customer_memberships_on_quoted_customer_id", using: :btree

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   limit: 4,     default: 0, null: false
    t.integer  "attempts",   limit: 4,     default: 0, null: false
    t.text     "handler",    limit: 65535,             null: false
    t.text     "last_error", limit: 65535
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by",  limit: 255
    t.string   "queue",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "document_types", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.string   "label_color", limit: 255
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "email_messages", force: :cascade do |t|
    t.text     "message",     limit: 65535
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.string   "uid",         limit: 255
    t.string   "rerecipient", limit: 255
  end

  create_table "enquiries", force: :cascade do |t|
    t.integer  "enquiry_type_id",           limit: 4
    t.integer  "user_id",                   limit: 4
    t.integer  "manager_id",                limit: 4
    t.string   "uid",                       limit: 255
    t.string   "first_name",                limit: 255
    t.string   "last_name",                 limit: 255
    t.string   "email",                     limit: 255
    t.string   "phone",                     limit: 255
    t.string   "company",                   limit: 255
    t.string   "job_title",                 limit: 255
    t.text     "details",                   limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "seen"
    t.boolean  "flagged"
    t.string   "status",                    limit: 255
    t.integer  "origin",                    limit: 4,     default: 0
    t.integer  "invoice_company_id",        limit: 4
    t.boolean  "customer_details_verified",               default: false
    t.boolean  "subscribe_to_newsletter",                 default: false
    t.string   "score",                     limit: 255
    t.string   "find_us",                   limit: 255
  end

  add_index "enquiries", ["created_at"], name: "index_enquiries_on_created_at", using: :btree
  add_index "enquiries", ["enquiry_type_id"], name: "index_enquiries_on_enquiry_type_id", using: :btree
  add_index "enquiries", ["id"], name: "index_enquiries_on_id", using: :btree
  add_index "enquiries", ["invoice_company_id"], name: "index_enquiries_on_invoice_company_id", using: :btree
  add_index "enquiries", ["manager_id"], name: "index_enquiries_on_manager_id", using: :btree
  add_index "enquiries", ["uid"], name: "index_enquiries_on_uid", using: :btree
  add_index "enquiries", ["user_id"], name: "index_enquiries_on_user_id", using: :btree

  create_table "enquiry_email_messages", force: :cascade do |t|
    t.integer  "enquiry_id",       limit: 4
    t.integer  "email_message_id", limit: 4
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  add_index "enquiry_email_messages", ["email_message_id"], name: "index_enquiry_email_messages_on_email_message_id", using: :btree
  add_index "enquiry_email_messages", ["enquiry_id"], name: "index_enquiry_email_messages_on_enquiry_id", using: :btree

  create_table "enquiry_email_uploads", force: :cascade do |t|
    t.string   "upload_file_name",    limit: 255
    t.string   "upload_content_type", limit: 255
    t.integer  "upload_file_size",    limit: 4
    t.integer  "upload_updated_at",   limit: 4
    t.integer  "enquiry_id",          limit: 4
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
    t.boolean  "email_sent",                      default: false
  end

  add_index "enquiry_email_uploads", ["enquiry_id"], name: "index_enquiry_email_uploads_on_enquiry_id", using: :btree

  create_table "enquiry_quotes", force: :cascade do |t|
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.integer  "enquiry_id", limit: 4
    t.integer  "quote_id",   limit: 4
  end

  create_table "enquiry_types", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "slug",       limit: 255
  end

  create_table "fee_types", force: :cascade do |t|
    t.string "category",    limit: 255
    t.string "name",        limit: 255
    t.string "charge_unit", limit: 255
  end

  add_index "fee_types", ["name"], name: "index_fee_types_on_name", unique: true, using: :btree

  create_table "file_uploads", force: :cascade do |t|
    t.string   "upload_file_name",    limit: 255
    t.string   "upload_content_type", limit: 255
    t.integer  "upload_file_size",    limit: 4
    t.datetime "upload_updated_at"
  end

  create_table "hire_addons", force: :cascade do |t|
    t.string   "addon_type",        limit: 255
    t.string   "hire_model_name",   limit: 255
    t.integer  "hire_price_cents",  limit: 4
    t.string   "billing_frequency", limit: 255
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  add_index "hire_addons", ["hire_model_name"], name: "index_hire_addons_on_hire_model_name", unique: true, using: :btree

  create_table "hire_agreement_type_uploads", force: :cascade do |t|
    t.integer  "hire_agreement_type_id", limit: 4
    t.string   "upload_file_name",       limit: 255
    t.string   "upload_content_type",    limit: 255
    t.integer  "upload_file_size",       limit: 4
    t.datetime "upload_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "hire_agreement_type_uploads", ["hire_agreement_type_id"], name: "index_hire_agreement_type_uploads_on_hire_agreement_type_id", using: :btree

  create_table "hire_agreement_types", force: :cascade do |t|
    t.string   "name",                limit: 255
    t.decimal  "damage_recovery_fee",             precision: 8, scale: 2
    t.decimal  "fuel_service_fee",                precision: 8, scale: 2
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "hire_agreements", force: :cascade do |t|
    t.integer  "vehicle_id",                    limit: 4
    t.integer  "customer_id",                   limit: 4
    t.integer  "manager_id",                    limit: 4
    t.string   "uid",                           limit: 25
    t.string   "status",                        limit: 25
    t.string   "driver_license_number",         limit: 255
    t.string   "driver_license_type",           limit: 255
    t.string   "driver_license_state_of_issue", limit: 255
    t.datetime "driver_license_expiry"
    t.datetime "driver_dob"
    t.datetime "pickup_time"
    t.datetime "return_time"
    t.string   "pickup_location",               limit: 255
    t.string   "return_location",               limit: 255
    t.integer  "seating_requirement",           limit: 4
    t.integer  "km_out",                        limit: 4
    t.integer  "km_in",                         limit: 4
    t.integer  "fuel_in",                       limit: 4
    t.integer  "daily_km_allowance",            limit: 4
    t.decimal  "daily_rate",                                  precision: 8, scale: 2
    t.decimal  "excess_km_rate",                              precision: 8, scale: 2
    t.decimal  "damage_recovery_fee",                         precision: 8, scale: 2
    t.decimal  "fuel_service_fee",                            precision: 8, scale: 2
    t.text     "details",                       limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "quote_id",                      limit: 4
    t.integer  "hire_agreement_type_id",        limit: 4
    t.datetime "demurrage_start_time"
    t.datetime "demurrage_end_time"
    t.decimal  "demurrage_rate",                              precision: 8, scale: 2
    t.integer  "invoice_company_id",            limit: 4
  end

  add_index "hire_agreements", ["customer_id"], name: "index_hire_agreements_on_customer_id", using: :btree
  add_index "hire_agreements", ["hire_agreement_type_id"], name: "index_hire_agreements_on_hire_agreement_type_id", using: :btree
  add_index "hire_agreements", ["invoice_company_id"], name: "index_hire_agreements_on_invoice_company_id", using: :btree
  add_index "hire_agreements", ["manager_id"], name: "index_hire_agreements_on_manager_id", using: :btree
  add_index "hire_agreements", ["quote_id"], name: "index_hire_agreements_on_quote_id", using: :btree
  add_index "hire_agreements", ["uid"], name: "index_hire_agreements_on_uid", using: :btree
  add_index "hire_agreements", ["vehicle_id"], name: "index_hire_agreements_on_vehicle_id", using: :btree

  create_table "hire_charges", force: :cascade do |t|
    t.integer  "hire_agreement_id",  limit: 4
    t.integer  "tax_id",             limit: 4
    t.string   "name",               limit: 255
    t.integer  "amount_cents",       limit: 4,   default: 0,     null: false
    t.string   "amount_currency",    limit: 255, default: "AUD", null: false
    t.string   "calculation_method", limit: 255
    t.integer  "quantity",           limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "hire_charges", ["hire_agreement_id"], name: "index_hire_charges_on_hire_agreement_id", using: :btree
  add_index "hire_charges", ["tax_id"], name: "index_hire_charges_on_tax_id", using: :btree

  create_table "hire_enquiries", force: :cascade do |t|
    t.integer "enquiry_id",              limit: 4
    t.date    "hire_start_date"
    t.string  "duration_unit",           limit: 255
    t.integer "units",                   limit: 4
    t.integer "number_of_vehicles",      limit: 4
    t.boolean "delivery_required",                   default: false
    t.string  "delivery_location",       limit: 255
    t.boolean "ongoing_contract",                    default: false
    t.string  "transmission_preference", limit: 255, default: "No Preference"
    t.integer "minimum_seats",           limit: 4,   default: 0
    t.string  "special_requirements",    limit: 255
  end

  add_index "hire_enquiries", ["enquiry_id"], name: "index_hire_enquiries_on_enquiry_id", using: :btree

  create_table "hire_fees", force: :cascade do |t|
    t.integer  "fee_type_id",     limit: 4
    t.integer  "chargeable_id",   limit: 4
    t.string   "chargeable_type", limit: 255
    t.integer  "fee_cents",       limit: 4
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  create_table "hire_product_types", force: :cascade do |t|
    t.string "name", limit: 255
  end

  create_table "hire_products", force: :cascade do |t|
    t.integer "vehicle_make_id",  limit: 4
    t.string  "model_name",       limit: 255
    t.integer "number_of_seats",  limit: 4,   default: 0
    t.string  "tags",             limit: 255
    t.integer "daily_rate_cents", limit: 4,   default: 0
    t.string  "license_type",     limit: 255
  end

  add_index "hire_products", ["vehicle_make_id", "model_name"], name: "idx_hire_product_on_make_model", using: :btree
  add_index "hire_products", ["vehicle_make_id"], name: "index_hire_products_on_vehicle_make_id", using: :btree

  create_table "hire_quote_addons", force: :cascade do |t|
    t.integer  "hire_addon_id",         limit: 4
    t.integer  "hire_quote_vehicle_id", limit: 4
    t.integer  "hire_price_cents",      limit: 4, default: 0
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
  end

  add_index "hire_quote_addons", ["hire_addon_id"], name: "index_hire_quote_addons_on_hire_addon_id", using: :btree
  add_index "hire_quote_addons", ["hire_quote_vehicle_id"], name: "index_hire_quote_addons_on_hire_quote_vehicle_id", using: :btree

  create_table "hire_quote_vehicles", force: :cascade do |t|
    t.integer "hire_quote_id",           limit: 4
    t.integer "hire_product_id",         limit: 4
    t.date    "start_date"
    t.date    "end_date"
    t.boolean "ongoing_contract",                    default: false
    t.boolean "delivery_required",                   default: false
    t.boolean "demobilisation_required",             default: false
    t.string  "pickup_location",         limit: 255
    t.string  "dropoff_location",        limit: 255
    t.integer "daily_rate_cents",        limit: 4
    t.string  "delivery_location",       limit: 255
    t.integer "vehicle_model_id",        limit: 4
  end

  add_index "hire_quote_vehicles", ["hire_quote_id"], name: "index_hire_quote_vehicles_on_hire_quote_id", using: :btree
  add_index "hire_quote_vehicles", ["vehicle_model_id"], name: "index_hire_quote_vehicles_on_vehicle_model_id", using: :btree

  create_table "hire_quotes", force: :cascade do |t|
    t.string   "uid",                   limit: 255
    t.integer  "customer_id",           limit: 4
    t.integer  "manager_id",            limit: 4
    t.integer  "enquiry_id",            limit: 4
    t.integer  "version",               limit: 4,   default: 1
    t.date     "start_date"
    t.string   "status",                limit: 255
    t.datetime "status_date"
    t.datetime "last_viewed"
    t.string   "tags",                  limit: 255
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
    t.string   "reference",             limit: 255
    t.integer  "authorised_contact_id", limit: 4
    t.date     "quoted_date"
  end

  add_index "hire_quotes", ["authorised_contact_id"], name: "index_hire_quotes_on_authorised_contact_id", using: :btree
  add_index "hire_quotes", ["customer_id"], name: "index_hire_quotes_on_customer_id", using: :btree
  add_index "hire_quotes", ["enquiry_id"], name: "index_hire_quotes_on_enquiry_id", using: :btree
  add_index "hire_quotes", ["manager_id"], name: "index_hire_quotes_on_manager_id", using: :btree
  add_index "hire_quotes", ["reference"], name: "index_hire_quotes_on_reference", using: :btree
  add_index "hire_quotes", ["tags"], name: "index_hire_quotes_on_tags", using: :btree
  add_index "hire_quotes", ["uid", "version"], name: "index_hire_quotes_on_uid_and_version", unique: true, using: :btree

  create_table "hire_uploads", force: :cascade do |t|
    t.integer  "hire_agreement_id",   limit: 4
    t.string   "upload_file_name",    limit: 255
    t.string   "upload_content_type", limit: 255
    t.integer  "upload_file_size",    limit: 4
    t.datetime "upload_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "hire_uploads", ["hire_agreement_id"], name: "index_hire_uploads_on_hire_agreement_id", using: :btree

  create_table "hire_vehicles", force: :cascade do |t|
    t.integer  "vehicle_id",         limit: 4
    t.integer  "daily_km_allowance", limit: 4
    t.decimal  "daily_rate",                   precision: 8, scale: 2
    t.decimal  "excess_km_rate",               precision: 8, scale: 2
    t.boolean  "active",                                               default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "hire_vehicles", ["vehicle_id"], name: "index_hire_vehicles_on_vehicle_id", using: :btree

  create_table "images", force: :cascade do |t|
    t.integer  "document_type_id",   limit: 4
    t.integer  "photo_category_id",  limit: 4
    t.integer  "imageable_id",       limit: 4
    t.string   "imageable_type",     limit: 255
    t.integer  "image_type",         limit: 4,   default: 0
    t.string   "name",               limit: 255
    t.string   "description",        limit: 255
    t.string   "image_file_name",    limit: 255
    t.string   "image_content_type", limit: 255
    t.integer  "image_file_size",    limit: 4
    t.datetime "image_updated_at"
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
  end

  add_index "images", ["imageable_id", "imageable_type"], name: "index_images_on_imageable_id_and_imageable_type", using: :btree

  create_table "invoice_companies", force: :cascade do |t|
    t.string   "name",              limit: 255
    t.string   "phone",             limit: 255
    t.string   "fax",               limit: 255
    t.string   "address_line_1",    limit: 255
    t.string   "address_line_2",    limit: 255
    t.string   "suburb",            limit: 255
    t.string   "state",             limit: 255
    t.string   "postcode",          limit: 255
    t.string   "country",           limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "logo_file_name",    limit: 255
    t.string   "logo_content_type", limit: 255
    t.integer  "logo_file_size",    limit: 4
    t.datetime "logo_updated_at"
    t.string   "abn",               limit: 255
    t.string   "acn",               limit: 255
    t.integer  "accounts_admin_id", limit: 4
    t.string   "slug",              limit: 255
    t.string   "website",           limit: 255
  end

  add_index "invoice_companies", ["accounts_admin_id"], name: "index_invoice_companies_on_accounts_admin_id", using: :btree

  create_table "job_subscribers", force: :cascade do |t|
    t.integer  "job_id",     limit: 4
    t.string   "job_type",   limit: 255
    t.integer  "user_id",    limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "job_subscribers", ["job_id", "job_type"], name: "index_job_subscribers_on_job_id_and_job_type", using: :btree
  add_index "job_subscribers", ["user_id"], name: "index_job_subscribers_on_user_id", using: :btree

  create_table "licences", force: :cascade do |t|
    t.integer  "user_id",             limit: 4
    t.string   "number",              limit: 255
    t.string   "state_of_issue",      limit: 255
    t.date     "expiry_date"
    t.string   "upload_file_name",    limit: 255
    t.string   "upload_content_type", limit: 255
    t.integer  "upload_file_size",    limit: 4
    t.datetime "upload_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "licences", ["user_id"], name: "index_licences_on_user_id", using: :btree

  create_table "log_uploads", force: :cascade do |t|
    t.integer  "vehicle_log_id",      limit: 4
    t.string   "upload_file_name",    limit: 255
    t.string   "upload_content_type", limit: 255
    t.integer  "upload_file_size",    limit: 4
    t.datetime "upload_updated_at"
  end

  add_index "log_uploads", ["vehicle_log_id"], name: "index_log_uploads_on_vehicle_log_id", using: :btree

  create_table "master_quote_items", force: :cascade do |t|
    t.integer  "master_quote_id",     limit: 4
    t.integer  "cost_tax_id",         limit: 4
    t.string   "name",                limit: 255
    t.text     "description",         limit: 65535
    t.integer  "cost_cents",          limit: 4,     default: 0,     null: false
    t.string   "cost_currency",       limit: 255,   default: "AUD", null: false
    t.integer  "quantity",            limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "position",            limit: 4
    t.integer  "supplier_id",         limit: 4
    t.integer  "service_provider_id", limit: 4
    t.integer  "buy_price_cents",     limit: 4,     default: 0,     null: false
    t.string   "buy_price_currency",  limit: 255,   default: "AUD", null: false
    t.integer  "buy_price_tax_id",    limit: 4
    t.integer  "quote_item_type_id",  limit: 4
    t.integer  "primary_order",       limit: 4,     default: 0
  end

  add_index "master_quote_items", ["cost_tax_id"], name: "index_master_quote_items_on_cost_tax_id", using: :btree
  add_index "master_quote_items", ["master_quote_id"], name: "index_master_quote_items_on_master_quote_id", using: :btree

  create_table "master_quote_items_quotes", id: false, force: :cascade do |t|
    t.integer "item_id",  limit: 4
    t.integer "quote_id", limit: 4
  end

  add_index "master_quote_items_quotes", ["item_id", "quote_id"], name: "index_master_quote_items_quotes_on_item_id_and_quote_id", using: :btree

  create_table "master_quote_specification_sheets", force: :cascade do |t|
    t.integer  "master_quote_id",     limit: 4
    t.string   "upload_file_name",    limit: 255
    t.string   "upload_content_type", limit: 255
    t.integer  "upload_file_size",    limit: 4
    t.datetime "upload_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "master_quote_specification_sheets", ["master_quote_id"], name: "index_master_quote_specification_sheets_on_master_quote_id", using: :btree

  create_table "master_quote_summary_pages", force: :cascade do |t|
    t.integer  "master_quote_id", limit: 4
    t.text     "text",            limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "master_quote_summary_pages", ["master_quote_id"], name: "index_master_quote_summary_pages_on_master_quote_id", using: :btree

  create_table "master_quote_title_pages", force: :cascade do |t|
    t.integer  "master_quote_id",      limit: 4
    t.string   "title",                limit: 255
    t.string   "image_1_file_name",    limit: 255
    t.string   "image_1_content_type", limit: 255
    t.integer  "image_1_file_size",    limit: 4
    t.datetime "image_1_updated_at"
    t.string   "image_2_file_name",    limit: 255
    t.string   "image_2_content_type", limit: 255
    t.integer  "image_2_file_size",    limit: 4
    t.datetime "image_2_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "master_quote_title_pages", ["master_quote_id"], name: "index_master_quote_title_pages_on_master_quote_id", using: :btree

  create_table "master_quote_types", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "master_quote_uploads", force: :cascade do |t|
    t.integer  "master_quote_id",     limit: 4
    t.string   "upload_file_name",    limit: 255
    t.string   "upload_content_type", limit: 255
    t.integer  "upload_file_size",    limit: 4
    t.datetime "upload_updated_at"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
  end

  add_index "master_quote_uploads", ["master_quote_id"], name: "index_master_quote_uploads_on_master_quote_id", using: :btree

  create_table "master_quotes", force: :cascade do |t|
    t.integer  "master_quote_type_id", limit: 4
    t.string   "vehicle_make",         limit: 255
    t.string   "vehicle_model",        limit: 255
    t.string   "name",                 limit: 255
    t.text     "terms",                limit: 65535
    t.text     "notes",                limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "transmission_type",    limit: 255
    t.integer  "seating_number",       limit: 4
    t.string   "international",        limit: 255
  end

  add_index "master_quotes", ["master_quote_type_id"], name: "index_master_quotes_on_master_quote_type_id", using: :btree

  create_table "messages", force: :cascade do |t|
    t.integer  "sender_id",         limit: 4
    t.integer  "recipient_id",      limit: 4
    t.integer  "workorder_id",      limit: 4
    t.integer  "hire_agreement_id", limit: 4
    t.integer  "quote_id",          limit: 4
    t.text     "comments",          limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "newsletter_subscriptions", force: :cascade do |t|
    t.string   "first_name",          limit: 255
    t.string   "last_name",           limit: 255
    t.string   "email",               limit: 255
    t.string   "subscription_origin", limit: 255
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
  end

  create_table "note_recipients", force: :cascade do |t|
    t.integer "note_id", limit: 4
    t.integer "user_id", limit: 4
  end

  create_table "note_uploads", force: :cascade do |t|
    t.integer  "note_id",             limit: 4
    t.string   "upload_file_name",    limit: 255
    t.string   "upload_content_type", limit: 255
    t.integer  "upload_file_size",    limit: 4
    t.datetime "upload_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "note_uploads", ["note_id"], name: "index_note_uploads_on_note_id", using: :btree

  create_table "notes", force: :cascade do |t|
    t.integer  "resource_id",     limit: 4
    t.string   "resource_type",   limit: 255
    t.integer  "author_id",       limit: 4
    t.boolean  "public"
    t.text     "comments",        limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "sched_time"
    t.integer  "reminder_status", limit: 4,     default: 0
  end

  add_index "notes", ["author_id"], name: "index_notes_on_author_id", using: :btree
  add_index "notes", ["resource_id", "resource_type"], name: "index_notes_on_resource_id_and_resource_type", using: :btree

  create_table "notification_types", force: :cascade do |t|
    t.string   "resource_name",          limit: 255
    t.string   "event_name",             limit: 255
    t.boolean  "recurring",                            default: false
    t.integer  "recur_period_days",      limit: 4,     default: 0
    t.boolean  "emails_required",                      default: false
    t.boolean  "upload_required",                      default: true
    t.string   "resource_document_type", limit: 255
    t.string   "label_color",            limit: 255
    t.text     "notify_periods",         limit: 65535
    t.text     "default_message",        limit: 65535
    t.datetime "created_at",                                           null: false
    t.datetime "updated_at",                                           null: false
  end

  create_table "notifications", force: :cascade do |t|
    t.integer  "notifiable_id",        limit: 4
    t.string   "notifiable_type",      limit: 255
    t.integer  "notification_type_id", limit: 4
    t.integer  "invoice_company_id",   limit: 4
    t.integer  "owner_id",             limit: 4
    t.integer  "completed_by_id",      limit: 4
    t.date     "due_date"
    t.date     "completed_date"
    t.boolean  "document_uploaded",                  default: false
    t.text     "email_message",        limit: 65535
    t.text     "recipients",           limit: 65535
    t.boolean  "send_emails",                        default: false
    t.text     "comments",             limit: 65535
    t.datetime "archived_at"
    t.datetime "created_at",                                         null: false
    t.datetime "updated_at",                                         null: false
  end

  add_index "notifications", ["completed_date"], name: "index_notifications_on_completed_date", using: :btree
  add_index "notifications", ["due_date"], name: "index_notifications_on_due_date", using: :btree
  add_index "notifications", ["invoice_company_id"], name: "index_notifications_on_invoice_company_id", using: :btree
  add_index "notifications", ["notifiable_id", "notifiable_type"], name: "index_notifications_on_notifiable_id_and_notifiable_type", using: :btree
  add_index "notifications", ["notification_type_id"], name: "index_notifications_on_notification_type_id", using: :btree
  add_index "notifications", ["owner_id"], name: "index_notifications_on_owner_id", using: :btree

  create_table "off_hire_job_uploads", force: :cascade do |t|
    t.integer  "off_hire_job_id",     limit: 4
    t.string   "upload_file_name",    limit: 255
    t.string   "upload_content_type", limit: 255
    t.integer  "upload_file_size",    limit: 4
    t.datetime "upload_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "off_hire_job_uploads", ["off_hire_job_id"], name: "index_off_hire_job_uploads_on_off_hire_job_id", using: :btree

  create_table "off_hire_jobs", force: :cascade do |t|
    t.integer  "off_hire_report_id",     limit: 4
    t.integer  "service_provider_id",    limit: 4
    t.integer  "manager_id",             limit: 4
    t.string   "name",                   limit: 255
    t.string   "uid",                    limit: 255
    t.string   "status",                 limit: 255
    t.datetime "sched_time"
    t.datetime "etc"
    t.text     "details",                limit: 65535
    t.text     "service_provider_notes", limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "invoice_company_id",     limit: 4
  end

  add_index "off_hire_jobs", ["invoice_company_id"], name: "index_off_hire_jobs_on_invoice_company_id", using: :btree
  add_index "off_hire_jobs", ["manager_id"], name: "index_off_hire_jobs_on_manager_id", using: :btree
  add_index "off_hire_jobs", ["off_hire_report_id"], name: "index_off_hire_jobs_on_off_hire_report_id", using: :btree
  add_index "off_hire_jobs", ["service_provider_id"], name: "index_off_hire_jobs_on_service_provider_id", using: :btree

  create_table "off_hire_report_uploads", force: :cascade do |t|
    t.integer  "off_hire_report_id",  limit: 4
    t.string   "upload_file_name",    limit: 255
    t.string   "upload_content_type", limit: 255
    t.integer  "upload_file_size",    limit: 4
    t.datetime "upload_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "off_hire_report_uploads", ["off_hire_report_id"], name: "index_off_hire_report_uploads_on_off_hire_report_id", using: :btree

  create_table "off_hire_reports", force: :cascade do |t|
    t.integer  "hire_agreement_id",              limit: 4
    t.integer  "user_id",                        limit: 4
    t.integer  "odometer_reading",               limit: 4
    t.datetime "report_time"
    t.string   "dropoff_person_first_name",      limit: 255
    t.string   "dropoff_person_last_name",       limit: 255
    t.string   "dropoff_person_phone",           limit: 255
    t.string   "dropoff_person_licence_number",  limit: 255
    t.text     "notes_exterior",                 limit: 65535
    t.text     "notes_interior",                 limit: 65535
    t.text     "notes_other",                    limit: 65535
    t.boolean  "spare_tyre_check"
    t.boolean  "tool_check"
    t.boolean  "wheel_nut_indicator_check"
    t.boolean  "triangle_stand_reflector_check"
    t.boolean  "first_aid_kit_check"
    t.boolean  "wheel_chock_check"
    t.boolean  "jump_start_lead_check"
    t.boolean  "fire_extinguisher_check"
    t.boolean  "mine_flag_check"
    t.boolean  "photo_check_front"
    t.boolean  "photo_check_rear"
    t.boolean  "photo_check_passenger_side"
    t.boolean  "photo_check_driver_side"
    t.boolean  "photo_check_fuel_gauge"
    t.boolean  "photo_check_rego_label"
    t.boolean  "photo_check_all_damages"
    t.integer  "fuel_litres",                    limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "photo_check_windscreen",                       default: false
    t.boolean  "check_lights",                                 default: false
    t.boolean  "check_horn",                                   default: false
    t.boolean  "check_windscreen_washer_bottle",               default: false
    t.boolean  "check_wiper_blades",                           default: false
    t.boolean  "check_service_sticker",                        default: false
    t.boolean  "check_windscreen_chips",                       default: false
    t.boolean  "check_vehicle_clean",                          default: false
  end

  add_index "off_hire_reports", ["hire_agreement_id"], name: "index_off_hire_reports_on_hire_agreement_id", using: :btree
  add_index "off_hire_reports", ["user_id"], name: "index_off_hire_reports_on_user_id", using: :btree

  create_table "on_hire_report_uploads", force: :cascade do |t|
    t.integer  "on_hire_report_id",   limit: 4
    t.string   "upload_file_name",    limit: 255
    t.string   "upload_content_type", limit: 255
    t.integer  "upload_file_size",    limit: 4
    t.datetime "upload_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "on_hire_report_uploads", ["on_hire_report_id"], name: "index_on_hire_report_uploads_on_on_hire_report_id", using: :btree

  create_table "on_hire_reports", force: :cascade do |t|
    t.integer  "hire_agreement_id",              limit: 4
    t.integer  "user_id",                        limit: 4
    t.integer  "odometer_reading",               limit: 4
    t.datetime "report_time"
    t.string   "pickup_person_first_name",       limit: 255
    t.string   "pickup_person_last_name",        limit: 255
    t.string   "pickup_person_phone",            limit: 255
    t.string   "pickup_person_licence_number",   limit: 255
    t.text     "notes_exterior",                 limit: 65535
    t.text     "notes_interior",                 limit: 65535
    t.text     "notes_other",                    limit: 65535
    t.boolean  "spare_tyre_check"
    t.boolean  "tool_check"
    t.boolean  "wheel_nut_indicator_check"
    t.boolean  "triangle_stand_reflector_check"
    t.boolean  "first_aid_kit_check"
    t.boolean  "wheel_chock_check"
    t.boolean  "jump_start_lead_check"
    t.boolean  "fire_extinguisher_check"
    t.boolean  "mine_flag_check"
    t.boolean  "photo_check_front"
    t.boolean  "photo_check_rear"
    t.boolean  "photo_check_passenger_side"
    t.boolean  "photo_check_driver_side"
    t.boolean  "photo_check_fuel_gauge"
    t.boolean  "photo_check_rego_label"
    t.boolean  "photo_check_all_damages"
    t.boolean  "fuel_check"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "photo_check_windscreen",                       default: false
    t.boolean  "check_lights",                                 default: false
    t.boolean  "check_horn",                                   default: false
    t.boolean  "check_windscreen_washer_bottle",               default: false
    t.boolean  "check_wiper_blades",                           default: false
    t.boolean  "check_service_sticker",                        default: false
    t.boolean  "check_windscreen_chips",                       default: false
    t.boolean  "check_vehicle_clean",                          default: false
  end

  add_index "on_hire_reports", ["hire_agreement_id"], name: "index_on_hire_reports_on_hire_agreement_id", using: :btree
  add_index "on_hire_reports", ["user_id"], name: "index_on_hire_reports_on_user_id", using: :btree

  create_table "photo_categories", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "po_request_uploads", force: :cascade do |t|
    t.integer  "po_request_id",       limit: 4
    t.string   "upload_file_name",    limit: 255
    t.string   "upload_content_type", limit: 255
    t.integer  "upload_file_size",    limit: 4
    t.datetime "upload_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "po_request_uploads", ["po_request_id"], name: "index_po_request_uploads_on_po_request_id", using: :btree

  create_table "po_requests", force: :cascade do |t|
    t.integer  "service_provider_id", limit: 4
    t.integer  "vehicle_id",          limit: 4
    t.string   "uid",                 limit: 255
    t.string   "vehicle_make",        limit: 255
    t.string   "vehicle_model",       limit: 255
    t.string   "vehicle_vin_number",  limit: 255
    t.datetime "sched_time"
    t.datetime "etc"
    t.boolean  "read"
    t.boolean  "flagged"
    t.string   "status",              limit: 255
    t.text     "details",             limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "po_requests", ["service_provider_id"], name: "index_po_requests_on_service_provider_id", using: :btree
  add_index "po_requests", ["vehicle_id"], name: "index_po_requests_on_vehicle_id", using: :btree

  create_table "quote_cover_letters", force: :cascade do |t|
    t.integer  "quote_id",   limit: 4
    t.string   "title",      limit: 255
    t.text     "text",       limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "quote_cover_letters", ["quote_id"], name: "index_quote_cover_letters_on_quote_id", using: :btree

  create_table "quote_item_types", force: :cascade do |t|
    t.string  "name",                 limit: 255
    t.integer "sort_order",           limit: 4,   default: 1
    t.boolean "allow_many_per_quote",             default: false
    t.integer "taxable",              limit: 4,   default: 1
  end

  create_table "quote_items", force: :cascade do |t|
    t.integer  "quote_id",             limit: 4
    t.integer  "tax_id",               limit: 4
    t.string   "name",                 limit: 255
    t.text     "description",          limit: 65535
    t.integer  "cost_cents",           limit: 4,     default: 0,     null: false
    t.string   "cost_currency",        limit: 255,   default: "AUD", null: false
    t.integer  "quantity",             limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "position",             limit: 4
    t.boolean  "hide_cost"
    t.integer  "supplier_id",          limit: 4
    t.integer  "service_provider_id",  limit: 4
    t.integer  "buy_price_cents",      limit: 4,     default: 0,     null: false
    t.string   "buy_price_currency",   limit: 255,   default: "AUD", null: false
    t.integer  "buy_price_tax_id",     limit: 4
    t.integer  "master_quote_item_id", limit: 4
    t.integer  "quote_item_type_id",   limit: 4
    t.integer  "primary_order",        limit: 4,     default: 0
    t.string   "line_total",           limit: 255
    t.string   "tax_total",            limit: 255
  end

  add_index "quote_items", ["master_quote_item_id"], name: "index_quote_items_on_master_quote_item_id", using: :btree
  add_index "quote_items", ["quote_id"], name: "index_quote_items_on_quote_id", using: :btree
  add_index "quote_items", ["tax_id"], name: "index_quote_items_on_tax_id", using: :btree

  create_table "quote_specification_sheets", force: :cascade do |t|
    t.integer  "quote_id",            limit: 4
    t.string   "upload_file_name",    limit: 255
    t.string   "upload_content_type", limit: 255
    t.integer  "upload_file_size",    limit: 4
    t.datetime "upload_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "quote_specification_sheets", ["quote_id"], name: "index_quote_specification_sheets_on_quote_id", using: :btree

  create_table "quote_summary_pages", force: :cascade do |t|
    t.integer  "quote_id",   limit: 4
    t.text     "text",       limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "quote_summary_pages", ["quote_id"], name: "index_quote_summary_pages_on_quote_id", using: :btree

  create_table "quote_title_pages", force: :cascade do |t|
    t.integer  "quote_id",             limit: 4
    t.string   "title",                limit: 255
    t.string   "image_1_file_name",    limit: 255
    t.string   "image_1_content_type", limit: 255
    t.integer  "image_1_file_size",    limit: 4
    t.datetime "image_1_updated_at"
    t.string   "image_2_file_name",    limit: 255
    t.string   "image_2_content_type", limit: 255
    t.integer  "image_2_file_size",    limit: 4
    t.datetime "image_2_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "quote_title_pages", ["quote_id"], name: "index_quote_title_pages_on_quote_id", using: :btree

  create_table "quote_uploads", force: :cascade do |t|
    t.integer  "quote_id",            limit: 4
    t.string   "upload_file_name",    limit: 255
    t.string   "upload_content_type", limit: 255
    t.integer  "upload_file_size",    limit: 4
    t.datetime "upload_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "quote_uploads", ["quote_id"], name: "index_quote_uploads_on_quote_id", using: :btree

  create_table "quotes", force: :cascade do |t|
    t.integer  "customer_id",            limit: 4
    t.integer  "manager_id",             limit: 4
    t.string   "number",                 limit: 25
    t.string   "po_number",              limit: 25
    t.date     "date"
    t.decimal  "discount",                             precision: 6, scale: 5
    t.string   "status",                 limit: 25
    t.text     "terms",                  limit: 65535
    t.text     "comments",               limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "invoice_company_id",     limit: 4
    t.string   "po_upload_file_name",    limit: 255
    t.string   "po_upload_content_type", limit: 255
    t.integer  "po_upload_file_size",    limit: 4
    t.datetime "po_upload_updated_at"
    t.integer  "total_cents",            limit: 4
    t.boolean  "amendment",                                                    default: false
    t.integer  "master_quote_id",        limit: 4
  end

  add_index "quotes", ["customer_id"], name: "index_quotes_on_customer_id", using: :btree
  add_index "quotes", ["id"], name: "index_quotes_on_id", using: :btree
  add_index "quotes", ["invoice_company_id"], name: "index_quotes_on_invoice_company_id", using: :btree
  add_index "quotes", ["manager_id"], name: "index_quotes_on_manager_id", using: :btree
  add_index "quotes", ["master_quote_id"], name: "index_quotes_on_master_quote_id", using: :btree
  add_index "quotes", ["number"], name: "index_quotes_on_number", using: :btree
  add_index "quotes", ["status"], name: "index_quotes_on_status", using: :btree

  create_table "sales_order_milestones", force: :cascade do |t|
    t.integer  "sales_order_id", limit: 4
    t.datetime "milestone_date"
    t.string   "description",    limit: 255
    t.boolean  "completed"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sales_order_milestones", ["sales_order_id"], name: "index_sales_order_milestones_on_sales_order_id", using: :btree

  create_table "sales_order_uploads", force: :cascade do |t|
    t.integer  "sales_order_id",      limit: 4
    t.string   "upload_file_name",    limit: 255
    t.string   "upload_content_type", limit: 255
    t.integer  "upload_file_size",    limit: 4
    t.datetime "upload_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sales_order_uploads", ["sales_order_id"], name: "index_sales_order_uploads_on_sales_order_id", using: :btree

  create_table "sales_orders", force: :cascade do |t|
    t.string   "number",                    limit: 255
    t.date     "order_date"
    t.integer  "quote_id",                  limit: 4
    t.integer  "build_id",                  limit: 4
    t.integer  "customer_id",               limit: 4
    t.integer  "manager_id",                limit: 4
    t.integer  "invoice_company_id",        limit: 4
    t.integer  "deposit_required_cents",    limit: 4,     default: 0,     null: false
    t.string   "deposit_required_currency", limit: 255,   default: "AUD", null: false
    t.boolean  "deposit_received"
    t.text     "details",                   limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sales_orders", ["build_id"], name: "index_sales_orders_on_build_id", using: :btree
  add_index "sales_orders", ["customer_id"], name: "index_sales_orders_on_customer_id", using: :btree
  add_index "sales_orders", ["invoice_company_id"], name: "index_sales_orders_on_invoice_company_id", using: :btree
  add_index "sales_orders", ["manager_id"], name: "index_sales_orders_on_manager_id", using: :btree
  add_index "sales_orders", ["quote_id"], name: "index_sales_orders_on_quote_id", using: :btree

  create_table "saved_quote_items", force: :cascade do |t|
    t.integer  "tax_id",        limit: 4
    t.string   "name",          limit: 255
    t.text     "description",   limit: 65535
    t.integer  "cost_cents",    limit: 4,     default: 0,     null: false
    t.string   "cost_currency", limit: 255,   default: "AUD", null: false
    t.integer  "quantity",      limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "saved_quote_items", ["tax_id"], name: "index_saved_quote_items_on_tax_id", using: :btree

  create_table "schedule_views", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "search_tags", force: :cascade do |t|
    t.string "tag_type", limit: 255
    t.string "name",     limit: 255
  end

  add_index "search_tags", ["tag_type", "name"], name: "index_search_tags_on_tag_type_and_name", unique: true, using: :btree

  create_table "sp_invoices", force: :cascade do |t|
    t.integer  "job_id",              limit: 4
    t.string   "job_type",            limit: 255
    t.string   "invoice_number",      limit: 255
    t.string   "status",              limit: 255
    t.string   "upload_file_name",    limit: 255
    t.string   "upload_content_type", limit: 255
    t.integer  "upload_file_size",    limit: 4
    t.datetime "upload_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sp_invoices", ["job_id", "job_type"], name: "index_sp_invoices_on_job_id_and_job_type", using: :btree

  create_table "stock_requests", force: :cascade do |t|
    t.integer  "invoice_company_id",      limit: 4
    t.integer  "supplier_id",             limit: 4
    t.integer  "customer_id",             limit: 4
    t.integer  "stock_id",                limit: 4
    t.string   "uid",                     limit: 25
    t.string   "status",                  limit: 25
    t.string   "vehicle_make",            limit: 255
    t.string   "vehicle_model",           limit: 255
    t.string   "transmission_type",       limit: 255
    t.date     "requested_delivery_date"
    t.text     "details",                 limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "stock_requests", ["customer_id"], name: "index_stock_requests_on_customer_id", using: :btree
  add_index "stock_requests", ["invoice_company_id"], name: "index_stock_requests_on_invoice_company_id", using: :btree
  add_index "stock_requests", ["stock_id"], name: "index_stock_requests_on_stock_id", using: :btree
  add_index "stock_requests", ["supplier_id"], name: "index_stock_requests_on_supplier_id", using: :btree
  add_index "stock_requests", ["uid"], name: "index_stock_requests_on_uid", using: :btree

  create_table "stocks", force: :cascade do |t|
    t.integer  "vehicle_model_id", limit: 4
    t.integer  "supplier_id",      limit: 4
    t.string   "stock_number",     limit: 25
    t.string   "vin_number",       limit: 50
    t.string   "transmission",     limit: 25
    t.string   "location",         limit: 255
    t.string   "books_and_keys",   limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "eta"
    t.string   "engine_number",    limit: 50
    t.string   "colour",           limit: 255
  end

  add_index "stocks", ["supplier_id"], name: "index_stocks_on_supplier_id", using: :btree
  add_index "stocks", ["vehicle_model_id"], name: "index_stocks_on_vehicle_model_id", using: :btree

  create_table "system_errors", force: :cascade do |t|
    t.integer  "resource_type",  limit: 4,     default: 0
    t.integer  "actioned_by_id", limit: 4
    t.integer  "error_status",   limit: 4,     default: 0
    t.text     "description",    limit: 65535
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.string   "user_email",     limit: 255
    t.string   "error_method",   limit: 255
    t.string   "error",          limit: 255
  end

  create_table "taggings", force: :cascade do |t|
    t.integer  "tag_id",        limit: 4
    t.integer  "taggable_id",   limit: 4
    t.string   "taggable_type", limit: 255
    t.integer  "tagger_id",     limit: 4
    t.string   "tagger_type",   limit: 255
    t.string   "context",       limit: 128
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true, using: :btree

  create_table "tags", force: :cascade do |t|
    t.string  "name",           limit: 255
    t.integer "taggings_count", limit: 4,   default: 0
  end

  add_index "tags", ["name"], name: "index_tags_on_name", unique: true, using: :btree

  create_table "taxes", force: :cascade do |t|
    t.string   "name",       limit: 25
    t.decimal  "rate",                  precision: 6, scale: 5
    t.string   "number",     limit: 25
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "position",   limit: 4
  end

  create_table "users", force: :cascade do |t|
    t.string   "first_name",              limit: 50
    t.string   "last_name",               limit: 50
    t.string   "phone",                   limit: 255
    t.string   "fax",                     limit: 255
    t.string   "mobile",                  limit: 255
    t.datetime "dob"
    t.string   "company",                 limit: 255
    t.string   "job_title",               limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "avatar_file_name",        limit: 255
    t.string   "avatar_content_type",     limit: 255
    t.integer  "avatar_file_size",        limit: 4
    t.datetime "avatar_updated_at"
    t.string   "email",                   limit: 255, default: "", null: false
    t.string   "encrypted_password",      limit: 255, default: "", null: false
    t.string   "reset_password_token",    limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",           limit: 4,   default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",      limit: 255
    t.string   "last_sign_in_ip",         limit: 255
    t.integer  "roles_mask",              limit: 4
    t.string   "authentication_token",    limit: 255
    t.string   "website",                 limit: 255
    t.datetime "archived_at"
    t.string   "xero_identifier",         limit: 255
    t.integer  "representing_company_id", limit: 4
    t.string   "abn",                     limit: 255
    t.integer  "employer_id",             limit: 4
    t.boolean  "receive_emails"
  end

  add_index "users", ["authentication_token"], name: "index_users_on_authentication_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["employer_id"], name: "index_users_on_employer_id", using: :btree
  add_index "users", ["representing_company_id"], name: "index_users_on_representing_company_id", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "vehicle_contract_statuses", force: :cascade do |t|
    t.integer  "vehicle_contract_id",   limit: 4
    t.integer  "changed_by_id",         limit: 4
    t.string   "name",                  limit: 255
    t.string   "signed_at_location_ip", limit: 255
    t.datetime "status_timestamp"
  end

  add_index "vehicle_contract_statuses", ["changed_by_id"], name: "index_vehicle_contract_statuses_on_changed_by_id", using: :btree
  add_index "vehicle_contract_statuses", ["vehicle_contract_id"], name: "index_vehicle_contract_statuses_on_vehicle_contract_id", using: :btree

  create_table "vehicle_contract_uploads", force: :cascade do |t|
    t.integer  "vehicle_contract_id",  limit: 4
    t.integer  "uploaded_by_id",       limit: 4
    t.string   "uploaded_location_ip", limit: 255
    t.datetime "original_upload_time"
    t.string   "upload_file_name",     limit: 255
    t.string   "upload_content_type",  limit: 255
    t.integer  "upload_file_size",     limit: 4
    t.datetime "upload_updated_at"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
  end

  add_index "vehicle_contract_uploads", ["uploaded_by_id"], name: "index_vehicle_contract_uploads_on_uploaded_by_id", using: :btree
  add_index "vehicle_contract_uploads", ["vehicle_contract_id"], name: "index_vehicle_contract_uploads_on_vehicle_contract_id", using: :btree

  create_table "vehicle_contracts", force: :cascade do |t|
    t.string   "uid",                       limit: 255
    t.integer  "customer_id",               limit: 4
    t.integer  "quote_id",                  limit: 4
    t.integer  "vehicle_id",                limit: 4
    t.integer  "invoice_company_id",        limit: 4
    t.integer  "manager_id",                limit: 4
    t.integer  "allocated_stock_id",        limit: 4
    t.integer  "deposit_received_cents",    limit: 4,     default: 0,     null: false
    t.string   "deposit_received_currency", limit: 255,   default: "AUD", null: false
    t.date     "deposit_received_date"
    t.string   "current_status",            limit: 255
    t.text     "special_conditions",        limit: 65535
    t.datetime "created_at",                                              null: false
    t.datetime "updated_at",                                              null: false
  end

  add_index "vehicle_contracts", ["customer_id"], name: "index_vehicle_contracts_on_customer_id", using: :btree
  add_index "vehicle_contracts", ["quote_id"], name: "index_vehicle_contracts_on_quote_id", using: :btree
  add_index "vehicle_contracts", ["uid"], name: "index_vehicle_contracts_on_uid", using: :btree
  add_index "vehicle_contracts", ["vehicle_id"], name: "index_vehicle_contracts_on_vehicle_id", using: :btree

  create_table "vehicle_logs", force: :cascade do |t|
    t.integer  "vehicle_id",          limit: 4
    t.integer  "workorder_id",        limit: 4
    t.string   "uid",                 limit: 25
    t.integer  "service_provider_id", limit: 4
    t.string   "name",                limit: 255
    t.string   "odometer_reading",    limit: 255
    t.string   "attachments",         limit: 255
    t.text     "details",             limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "flagged"
    t.text     "follow_up_message",   limit: 65535
  end

  add_index "vehicle_logs", ["service_provider_id"], name: "index_vehicle_logs_on_service_provider_id", using: :btree
  add_index "vehicle_logs", ["uid"], name: "index_vehicle_logs_on_uid", using: :btree
  add_index "vehicle_logs", ["vehicle_id"], name: "index_vehicle_logs_on_vehicle_id", using: :btree
  add_index "vehicle_logs", ["workorder_id"], name: "index_vehicle_logs_on_workorder_id", using: :btree

  create_table "vehicle_makes", force: :cascade do |t|
    t.string "name", limit: 50
  end

  create_table "vehicle_models", force: :cascade do |t|
    t.integer  "vehicle_make_id",  limit: 4
    t.string   "name",             limit: 50
    t.integer  "year",             limit: 4
    t.integer  "number_of_seats",  limit: 4,   default: 0
    t.string   "tags",             limit: 255
    t.integer  "daily_rate_cents", limit: 4,   default: 0
    t.string   "license_type",     limit: 255
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
  end

  add_index "vehicle_models", ["vehicle_make_id"], name: "index_vehicle_models_on_vehicle_make_id", using: :btree

  create_table "vehicle_models_addons", force: :cascade do |t|
    t.integer "vehicle_model_id", limit: 4
    t.integer "hire_addon_id",    limit: 4
  end

  add_index "vehicle_models_addons", ["hire_addon_id"], name: "index_vehicle_models_addons_on_hire_addon_id", using: :btree
  add_index "vehicle_models_addons", ["vehicle_model_id", "hire_addon_id"], name: "models_addons_index", unique: true, using: :btree
  add_index "vehicle_models_addons", ["vehicle_model_id"], name: "index_vehicle_models_addons_on_vehicle_model_id", using: :btree

  create_table "vehicle_models_hire_product_types", force: :cascade do |t|
    t.integer "vehicle_model_id",     limit: 4
    t.integer "hire_product_type_id", limit: 4
  end

  add_index "vehicle_models_hire_product_types", ["hire_product_type_id"], name: "index_vehicle_models_hire_product_types_on_hire_product_type_id", using: :btree
  add_index "vehicle_models_hire_product_types", ["vehicle_model_id", "hire_product_type_id"], name: "vehicle_models_product_types_index", unique: true, using: :btree
  add_index "vehicle_models_hire_product_types", ["vehicle_model_id"], name: "index_vehicle_models_hire_product_types_on_vehicle_model_id", using: :btree

  create_table "vehicle_schedule_views", force: :cascade do |t|
    t.integer  "vehicle_id",       limit: 4
    t.integer  "schedule_view_id", limit: 4
    t.integer  "position",         limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "vehicle_schedule_views", ["schedule_view_id"], name: "index_vehicle_schedule_views_on_schedule_view_id", using: :btree
  add_index "vehicle_schedule_views", ["vehicle_id"], name: "index_vehicle_schedule_views_on_vehicle_id", using: :btree

  create_table "vehicle_uploads", force: :cascade do |t|
    t.integer  "vehicle_id",          limit: 4
    t.string   "upload_file_name",    limit: 255
    t.string   "upload_content_type", limit: 255
    t.integer  "upload_file_size",    limit: 4
    t.datetime "upload_updated_at"
  end

  add_index "vehicle_uploads", ["vehicle_id"], name: "index_vehicle_uploads_on_vehicle_id", using: :btree

  create_table "vehicles", force: :cascade do |t|
    t.integer  "vehicle_model_id",      limit: 4
    t.integer  "supplier_id",           limit: 4
    t.integer  "owner_id",              limit: 4
    t.string   "build_number",          limit: 25
    t.string   "stock_number",          limit: 25
    t.string   "vin_number",            limit: 50
    t.string   "vehicle_number",        limit: 50
    t.string   "engine_number",         limit: 50
    t.string   "transmission",          limit: 25
    t.string   "location",              limit: 255
    t.string   "books_and_keys",        limit: 255
    t.string   "mod_plate",             limit: 255
    t.string   "odometer_reading",      limit: 255
    t.integer  "seating_capacity",      limit: 4
    t.string   "rego_number",           limit: 25
    t.date     "rego_due_date"
    t.string   "order_number",          limit: 255
    t.string   "invoice_number",        limit: 255
    t.string   "kit_number",            limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "license_required",      limit: 255
    t.boolean  "exclude_from_schedule"
    t.date     "delivery_date"
    t.string   "class_type",            limit: 255
    t.string   "call_sign",             limit: 255
    t.string   "body_type",             limit: 255
    t.date     "build_date"
    t.string   "colour",                limit: 255
    t.string   "engine_type",           limit: 255
    t.string   "status",                limit: 255
    t.date     "status_date"
    t.string   "fuel_type",             limit: 255, default: "diesel"
    t.string   "usage_status",          limit: 255, default: "not ready"
    t.string   "operational_status",    limit: 255, default: "roadworthy"
    t.string   "tags",                  limit: 255
    t.integer  "model_year",            limit: 4
  end

  add_index "vehicles", ["owner_id"], name: "index_vehicles_on_owner_id", using: :btree
  add_index "vehicles", ["supplier_id"], name: "index_vehicles_on_supplier_id", using: :btree
  add_index "vehicles", ["vehicle_model_id"], name: "index_vehicles_on_vehicle_model_id", using: :btree

  create_table "workorder_type_uploads", force: :cascade do |t|
    t.integer  "workorder_type_id",   limit: 4
    t.string   "upload_file_name",    limit: 255
    t.string   "upload_content_type", limit: 255
    t.integer  "upload_file_size",    limit: 4
    t.datetime "upload_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "workorder_type_uploads", ["workorder_type_id"], name: "index_workorder_type_uploads_on_workorder_type_id", using: :btree

  create_table "workorder_types", force: :cascade do |t|
    t.string "name",        limit: 255
    t.string "label_color", limit: 255
    t.text   "notes",       limit: 65535
  end

  create_table "workorder_uploads", force: :cascade do |t|
    t.integer  "workorder_id",        limit: 4
    t.string   "upload_file_name",    limit: 255
    t.string   "upload_content_type", limit: 255
    t.integer  "upload_file_size",    limit: 4
    t.datetime "upload_updated_at"
  end

  add_index "workorder_uploads", ["workorder_id"], name: "index_workorder_uploads_on_workorder_id", using: :btree

  create_table "workorders", force: :cascade do |t|
    t.integer  "vehicle_id",          limit: 4
    t.integer  "workorder_type_id",   limit: 4
    t.string   "uid",                 limit: 25
    t.string   "status",              limit: 25
    t.boolean  "is_recurring",                      default: false
    t.integer  "recurring_period",    limit: 4
    t.integer  "service_provider_id", limit: 4
    t.integer  "customer_id",         limit: 4
    t.integer  "manager_id",          limit: 4
    t.datetime "sched_time"
    t.datetime "etc"
    t.text     "details",             limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "invoice_company_id",  limit: 4
  end

  add_index "workorders", ["customer_id"], name: "index_workorders_on_customer_id", using: :btree
  add_index "workorders", ["invoice_company_id"], name: "index_workorders_on_invoice_company_id", using: :btree
  add_index "workorders", ["manager_id"], name: "index_workorders_on_manager_id", using: :btree
  add_index "workorders", ["service_provider_id"], name: "index_workorders_on_service_provider_id", using: :btree
  add_index "workorders", ["uid"], name: "index_workorders_on_uid", using: :btree
  add_index "workorders", ["vehicle_id"], name: "index_workorders_on_vehicle_id", using: :btree
  add_index "workorders", ["workorder_type_id"], name: "index_workorders_on_workorder_type_id", using: :btree

  add_foreign_key "enquiry_email_messages", "email_messages"
  add_foreign_key "enquiry_email_messages", "enquiries"
  add_foreign_key "enquiry_email_uploads", "enquiries"
end
