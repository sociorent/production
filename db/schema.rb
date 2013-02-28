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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130226172158) do

  create_table "active_admin_comments", :force => true do |t|
    t.string   "resource_id",   :null => false
    t.string   "resource_type", :null => false
    t.integer  "author_id"
    t.string   "author_type"
    t.text     "body"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.string   "namespace"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], :name => "index_active_admin_comments_on_author_type_and_author_id"
  add_index "active_admin_comments", ["namespace"], :name => "index_active_admin_comments_on_namespace"
  add_index "active_admin_comments", ["resource_type", "resource_id"], :name => "index_admin_notes_on_resource_type_and_resource_id"

  create_table "ambassadors", :force => true do |t|
    t.integer  "college_id"
    t.datetime "created_at",            :null => false
    t.datetime "updated_at",            :null => false
    t.integer  "ambassador_manager_id"
  end

  add_index "ambassadors", ["college_id"], :name => "index_ambassadors_on_college_id"

  create_table "ambassadors_colleges", :force => true do |t|
    t.integer "ambassador_id"
    t.integer "college_id"
  end

  create_table "banks", :force => true do |t|
    t.string   "name"
    t.text     "details"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "book_apis", :force => true do |t|
    t.string   "book"
    t.string   "author"
    t.string   "isbn"
    t.string   "isbn13"
    t.string   "binding"
    t.string   "publishing_date"
    t.string   "publisher"
    t.string   "edition"
    t.integer  "number_of_pages"
    t.string   "language"
    t.datetime "created_at",                                     :null => false
    t.datetime "updated_at",                                     :null => false
    t.text     "image_url"
    t.string   "availability"
    t.decimal  "price",           :precision => 10, :scale => 2
    t.text     "description"
    t.string   "college"
    t.string   "stream"
  end

  create_table "book_carts", :force => true do |t|
    t.integer  "book_id"
    t.integer  "cart_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "book_colleges", :force => true do |t|
    t.integer  "book_id"
    t.integer  "college_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "book_colleges", ["book_id"], :name => "index_book_colleges_on_book_id"
  add_index "book_colleges", ["college_id"], :name => "index_book_colleges_on_college_id"

  create_table "book_orders", :force => true do |t|
    t.integer  "book_id"
    t.integer  "order_id"
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
    t.boolean  "shipped",         :default => false
    t.string   "courier_name"
    t.string   "tracking_number"
    t.datetime "shipped_date"
    t.string   "status"
  end

  add_index "book_orders", ["book_id"], :name => "index_book_orders_on_book_id"
  add_index "book_orders", ["order_id"], :name => "index_book_orders_on_order_id"

  create_table "book_semesters", :force => true do |t|
    t.integer  "book_id"
    t.integer  "semester_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "book_semesters", ["book_id"], :name => "index_book_semesters_on_book_id"
  add_index "book_semesters", ["semester_id"], :name => "index_book_semesters_on_semester_id"

  create_table "book_streams", :force => true do |t|
    t.integer  "book_id"
    t.integer  "stream_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "book_streams", ["book_id"], :name => "index_book_streams_on_book_id"
  add_index "book_streams", ["stream_id"], :name => "index_book_streams_on_stream_id"

  create_table "books", :force => true do |t|
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
    t.string   "name"
    t.text     "description"
    t.string   "isbn10"
    t.string   "author"
    t.string   "isbn13"
    t.string   "binding"
    t.string   "published"
    t.integer  "pages"
    t.integer  "price"
    t.text     "strengths"
    t.text     "weaknesses"
    t.integer  "category_id"
    t.string   "edition"
    t.integer  "new_book_price"
    t.integer  "old_book_price"
    t.integer  "rank"
    t.integer  "publisher_id"
    t.string   "availability"
    t.boolean  "delta",          :default => true
  end

  create_table "carts", :force => true do |t|
    t.integer  "user_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "categories", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "class_adoptions", :force => true do |t|
    t.integer  "rate"
    t.integer  "book_id"
    t.integer  "college_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "class_adoptions", ["book_id"], :name => "index_class_adoptions_on_book_id"
  add_index "class_adoptions", ["college_id"], :name => "index_class_adoptions_on_college_id"

  create_table "colleges", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "companies", :force => true do |t|
    t.string   "name"
    t.string   "offer_position"
    t.integer  "offer_stipend"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "company_users", :force => true do |t|
    t.integer  "company_id"
    t.integer  "user_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "company_users", ["company_id"], :name => "index_company_users_on_company_id"
  add_index "company_users", ["user_id"], :name => "index_company_users_on_user_id"

  create_table "counters", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "name"
    t.integer  "college_id"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
  end

  add_index "counters", ["email"], :name => "index_counters_on_email", :unique => true
  add_index "counters", ["reset_password_token"], :name => "index_counters_on_reset_password_token", :unique => true

  create_table "csvuploads", :force => true do |t|
    t.integer  "books_uploaded"
    t.integer  "total_books"
    t.text     "isbns_not_uploaded"
    t.string   "status"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
    t.string   "csv_file_name"
    t.string   "csv_content_type"
    t.integer  "csv_file_size"
    t.datetime "csv_updated_at"
  end

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "general_images", :force => true do |t|
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.integer  "general_id"
  end

  create_table "generals", :force => true do |t|
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
    t.string   "intelligent_book"
    t.string   "welcome_mail_subject"
    t.text     "welcome_mail_content"
    t.string   "order_email_subject"
    t.text     "order_email_content"
    t.text     "address"
  end

  create_table "images", :force => true do |t|
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.integer  "imageable_id"
    t.string   "imageable_type"
  end

  create_table "orders", :force => true do |t|
    t.string   "random"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.integer  "user_id"
    t.integer  "total"
    t.integer  "rental_total"
    t.string   "order_type"
    t.boolean  "payment_done",        :default => false
    t.integer  "deposit_total"
    t.integer  "bank_id"
    t.string   "gharpay_id"
    t.boolean  "accept_terms_of_use"
    t.string   "citruspay_response"
    t.string   "COD_mobile"
    t.string   "status"
  end

  create_table "p2p_categories", :force => true do |t|
    t.string   "name"
    t.integer  "category_id"
    t.datetime "created_at",                                                    :null => false
    t.datetime "updated_at",                                                    :null => false
    t.integer  "priority"
    t.decimal  "courier_charge", :precision => 3, :scale => 2, :default => 0.0
  end

  add_index "p2p_categories", ["category_id"], :name => "index_p2p_categories_on_category_id"

  create_table "p2p_cities", :force => true do |t|
    t.string   "name"
    t.string   "latitude"
    t.string   "longitude"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
    t.integer  "pickup",     :default => 0
  end

  create_table "p2p_credits", :force => true do |t|
    t.integer  "user_id"
    t.integer  "type",         :default => 1
    t.integer  "totalCredits"
    t.integer  "available"
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
  end

  add_index "p2p_credits", ["user_id"], :name => "index_p2p_credits_on_user_id"

  create_table "p2p_images", :force => true do |t|
    t.integer  "item_id"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.string   "img_file_name"
    t.string   "img_content_type"
    t.integer  "img_file_size"
    t.datetime "img_updated_at"
  end

  add_index "p2p_images", ["item_id"], :name => "index_p2p_images_on_item_id"

  create_table "p2p_item_histories", :force => true do |t|
    t.integer  "item_id"
    t.string   "columnname"
    t.string   "oldvalue"
    t.string   "newvalue"
    t.boolean  "approved"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "p2p_item_histories", ["item_id"], :name => "index_p2p_item_histories_on_item_id"

  create_table "p2p_item_specs", :force => true do |t|
    t.integer  "spec_id"
    t.string   "value"
    t.integer  "item_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "p2p_item_specs", ["item_id"], :name => "index_p2p_item_specs_on_item_id"
  add_index "p2p_item_specs", ["spec_id"], :name => "index_p2p_item_specs_on_spec_id"

  create_table "p2p_items", :force => true do |t|
    t.integer  "product_id"
    t.integer  "user_id"
    t.string   "title"
    t.text     "desc"
    t.integer  "paytype"
    t.datetime "solddate"
    t.datetime "paiddate"
    t.datetime "delivereddate"
    t.integer  "viewcount",                                     :default => 0
    t.integer  "reqCount",                                      :default => 0
    t.float    "price"
    t.integer  "city_id"
    t.datetime "created_at",                                                   :null => false
    t.datetime "updated_at",                                                   :null => false
    t.string   "condition"
    t.datetime "disapproveddate"
    t.datetime "approveddate"
    t.string   "payinfo"
    t.decimal  "commision",       :precision => 3, :scale => 2
    t.datetime "deletedate"
  end

  add_index "p2p_items", ["city_id"], :name => "index_p2p_items_on_city_id"
  add_index "p2p_items", ["product_id"], :name => "index_p2p_items_on_product_id"
  add_index "p2p_items", ["user_id"], :name => "index_p2p_items_on_user_id"

  create_table "p2p_messages", :force => true do |t|
    t.integer  "sender"
    t.integer  "receiver"
    t.string   "item_id"
    t.text     "message"
    t.datetime "readdatetime"
    t.integer  "messagetype",     :default => 0
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
    t.integer  "sender_id"
    t.integer  "receiver_id"
    t.string   "flag"
    t.string   "sender_status"
    t.integer  "parent_id"
    t.string   "receiver_status"
  end

  add_index "p2p_messages", ["parent_id"], :name => "index_p2p_messages_on_parent_id"
  add_index "p2p_messages", ["receiver_id"], :name => "index_p2p_messages_on_receiver_id"
  add_index "p2p_messages", ["sender_id"], :name => "index_p2p_messages_on_sender_id"

  create_table "p2p_products", :force => true do |t|
    t.string   "name"
    t.integer  "category_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.integer  "priority"
  end

  add_index "p2p_products", ["category_id"], :name => "index_p2p_products_on_category_id"

  create_table "p2p_service_pincodes", :force => true do |t|
    t.string   "pincode"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "p2p_specs", :force => true do |t|
    t.string   "name"
    t.integer  "display_type", :default => 1
    t.integer  "parent_id"
    t.integer  "category_id"
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
    t.integer  "priority"
  end

  add_index "p2p_specs", ["category_id"], :name => "index_p2p_specs_on_category_id"

  create_table "p2p_users", :force => true do |t|
    t.integer  "user_id"
    t.boolean  "mobileverified", :default => false
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
  end

  add_index "p2p_users", ["user_id"], :name => "index_p2p_users_on_user_id"

  create_table "pincodes", :force => true do |t|
    t.integer  "pincode"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "publishers", :force => true do |t|
    t.integer  "rental"
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "rails_admin_histories", :force => true do |t|
    t.text     "message"
    t.string   "username"
    t.integer  "item"
    t.string   "table"
    t.integer  "month",      :limit => 2
    t.integer  "year",       :limit => 8
    t.datetime "created_at",              :null => false
    t.datetime "updated_at",              :null => false
  end

  add_index "rails_admin_histories", ["item", "table", "month", "year"], :name => "index_rails_admin_histories"

  create_table "requests", :force => true do |t|
    t.string   "title"
    t.string   "author"
    t.integer  "user_id"
    t.string   "isbn"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "requests", ["user_id"], :name => "index_requests_on_user_id"

  create_table "resources", :force => true do |t|
    t.string   "name"
    t.string   "link"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "reviews", :force => true do |t|
    t.text     "content"
    t.integer  "book_id"
    t.integer  "user_id"
    t.float    "rating"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "semester"
  end

  create_table "semesters", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "shippings", :force => true do |t|
    t.integer  "book_order_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "sms", :force => true do |t|
    t.string   "sms_type"
    t.text     "content"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "static_pages", :force => true do |t|
    t.string   "page_name"
    t.string   "page_title"
    t.boolean  "is_active",                          :default => true
    t.datetime "created_at",                                           :null => false
    t.datetime "updated_at",                                           :null => false
    t.text     "page_content", :limit => 2147483647
  end

  create_table "streams", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "email",                               :default => "", :null => false
    t.string   "encrypted_password",                  :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                       :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                                          :null => false
    t.datetime "updated_at",                                          :null => false
    t.string   "provider"
    t.integer  "uid",                    :limit => 8
    t.string   "name"
    t.boolean  "is_admin"
    t.integer  "college_id"
    t.string   "mobile_number"
    t.text     "friends"
    t.integer  "stream_id"
    t.text     "wishlist"
    t.integer  "ambassador_id"
    t.string   "image"
    t.text     "address"
    t.string   "unique_id"
    t.string   "token"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
