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

ActiveRecord::Schema.define(:version => 20130407054030) do

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

  create_table "ex_centers", :id => false, :force => true do |t|
    t.integer "ex_centers_id",              :null => false
    t.string  "cid",           :limit => 6, :null => false
    t.string  "sid",           :limit => 3, :null => false
    t.date    "pricedate",                  :null => false
  end

  add_index "ex_centers", ["cid", "sid", "pricedate"], :name => "ex_centers_ix02"
  add_index "ex_centers", ["ex_centers_id"], :name => "ex_centers_ix01"

  create_table "ex_combined", :id => false, :force => true do |t|
    t.string  "cid",           :limit => 6, :null => false
    t.string  "sid",           :limit => 3, :null => false
    t.string  "idxsec",        :limit => 2, :null => false
    t.string  "idxgrp",        :limit => 4, :null => false
    t.string  "idxind",        :limit => 6, :null => false
    t.string  "idxsub",        :limit => 8, :null => false
    t.integer "idxnew",                     :null => false
    t.integer "idxcapl",                    :null => false
    t.integer "idxcaph",                    :null => false
    t.date    "pricedate",                  :null => false
    t.date    "fpedate",                    :null => false
    t.date    "fromdate",                   :null => false
    t.date    "thrudate",                   :null => false
    t.float   "csho"
    t.float   "ajex"
    t.float   "price"
    t.float   "volume"
    t.float   "pch1m"
    t.float   "pch3m"
    t.float   "pch6m"
    t.float   "pch9m"
    t.float   "pch12m"
    t.float   "dvpsxm_ttm"
    t.float   "epspiq_ttm"
    t.float   "epspxq_ttm"
    t.float   "epspiq_10yISr"
    t.float   "niq_ttm"
    t.float   "oiadpq_ttm"
    t.float   "cogsq_ttm"
    t.float   "saleq_ttm"
    t.float   "saleq_4yISgx"
    t.float   "seqq_mrq"
    t.float   "cheq_mrq"
    t.float   "actq_mrq"
    t.float   "ppentq_mrq"
    t.float   "atq_mrq"
    t.float   "dlcq_mrq"
    t.float   "lctq_mrq"
    t.float   "dlttq_mrq"
    t.float   "pstkq_mrq"
    t.float   "mibnq_mrq"
    t.float   "mibq_mrq"
    t.float   "fcfq_ttm"
    t.float   "fcfq_4yISm"
  end

  add_index "ex_combined", ["cid", "sid", "fromdate", "thrudate"], :name => "ex_combined_ix01"
  add_index "ex_combined", ["idxgrp", "idxnew", "pricedate", "idxcapl", "idxcaph"], :name => "ex_combined_ix03"
  add_index "ex_combined", ["idxind", "idxnew", "pricedate", "idxcapl", "idxcaph"], :name => "ex_combined_ix04"
  add_index "ex_combined", ["idxsec", "idxnew", "pricedate", "idxcapl", "idxcaph"], :name => "ex_combined_ix02"
  add_index "ex_combined", ["idxsub", "idxnew", "pricedate", "idxcapl", "idxcaph"], :name => "ex_combined_ix05"
  add_index "ex_combined", ["pricedate"], :name => "ex_combined_ix10"

  create_table "ex_dists", :id => false, :force => true do |t|
    t.integer "ex_centers_id",              :null => false
    t.string  "cid",           :limit => 6, :null => false
    t.string  "sid",           :limit => 3, :null => false
    t.date    "pricedate",                  :null => false
    t.float   "dist"
  end

  add_index "ex_dists", ["cid", "sid", "pricedate"], :name => "ex_dist_ix02"
  add_index "ex_dists", ["dist"], :name => "ex_dist_ix03"
  add_index "ex_dists", ["ex_centers_id"], :name => "ex_dist_ix01"

  create_table "ex_econ", :id => false, :force => true do |t|
    t.date  "datadate", :null => false
    t.float "cape"
    t.float "tbill1mo"
    t.float "tbill6mo"
    t.float "note10yr"
  end

  add_index "ex_econ", ["datadate"], :name => "ex_econ_ix01"

  create_table "ex_factdata", :id => false, :force => true do |t|
    t.string  "cid",           :limit => 6, :null => false
    t.string  "sid",           :limit => 3, :null => false
    t.date    "fromdate",                   :null => false
    t.date    "thrudate",                   :null => false
    t.date    "datadate",                   :null => false
    t.string  "idxsec",        :limit => 2, :null => false
    t.string  "idxgrp",        :limit => 4, :null => false
    t.string  "idxind",        :limit => 6, :null => false
    t.string  "idxsub",        :limit => 8, :null => false
    t.integer "idxnew",                     :null => false
    t.integer "idxcapl",                    :null => false
    t.integer "idxcaph",                    :null => false
    t.float   "dvpsxm_ttm"
    t.float   "epspiq_ttm"
    t.float   "epspxq_ttm"
    t.float   "epspiq_10yISr"
    t.float   "niq_ttm"
    t.float   "oiadpq_ttm"
    t.float   "cogsq_ttm"
    t.float   "saleq_ttm"
    t.float   "saleq_4yISgx"
    t.float   "seqq_mrq"
    t.float   "cheq_mrq"
    t.float   "actq_mrq"
    t.float   "ppentq_mrq"
    t.float   "atq_mrq"
    t.float   "dlcq_mrq"
    t.float   "lctq_mrq"
    t.float   "dlttq_mrq"
    t.float   "pstkq_mrq"
    t.float   "mibnq_mrq"
    t.float   "mibq_mrq"
    t.float   "fcfq_ttm"
    t.float   "fcfq_4yISm"
  end

  add_index "ex_factdata", ["cid", "sid", "fromdate", "thrudate"], :name => "ex_factdata_ix01"
  add_index "ex_factdata", ["idxgrp", "idxnew", "idxcapl", "idxcaph"], :name => "ex_factdata_ix03"
  add_index "ex_factdata", ["idxind", "idxnew", "idxcapl", "idxcaph"], :name => "ex_factdata_ix04"
  add_index "ex_factdata", ["idxsec", "idxnew", "idxcapl", "idxcaph"], :name => "ex_factdata_ix02"
  add_index "ex_factdata", ["idxsub", "idxnew", "idxcapl", "idxcaph"], :name => "ex_factdata_ix05"

  create_table "ex_fundmts", :id => false, :force => true do |t|
    t.string "cid",      :limit => 6, :null => false
    t.string "sid",      :limit => 3, :null => false
    t.date   "fromdate",              :null => false
    t.date   "thrudate",              :null => false
    t.date   "datadate",              :null => false
    t.string "type",     :limit => 3, :null => false
    t.float  "sale"
    t.float  "cogs"
    t.float  "gross"
    t.float  "xsga"
    t.float  "xrd"
    t.float  "dp"
    t.float  "xint"
    t.float  "xopit"
    t.float  "opi"
    t.float  "nooth"
    t.float  "pi"
    t.float  "txt"
    t.float  "mii"
    t.float  "dvp"
    t.float  "xido"
    t.float  "ni"
    t.float  "epspx"
    t.float  "epspi"
    t.float  "epsfx"
    t.float  "epsfi"
    t.float  "cshpr"
    t.float  "cshfd"
    t.float  "che"
    t.float  "rect"
    t.float  "invt"
    t.float  "aco"
    t.float  "act"
    t.float  "ppent"
    t.float  "gdwl"
    t.float  "intano"
    t.float  "ivlt"
    t.float  "alto"
    t.float  "at"
    t.float  "dlc"
    t.float  "ap"
    t.float  "txp"
    t.float  "lco"
    t.float  "lct"
    t.float  "dltt"
    t.float  "txditc"
    t.float  "lo"
    t.float  "lt"
    t.float  "pstk"
    t.float  "ceq"
    t.float  "cstk"
    t.float  "caps"
    t.float  "re"
    t.float  "tstk"
    t.float  "seq"
    t.float  "lse"
    t.float  "csho"
    t.float  "cshi"
    t.float  "oancf"
    t.float  "capx"
    t.float  "dv"
    t.float  "fcf"
  end

  add_index "ex_fundmts", ["cid", "sid", "fromdate", "thrudate", "type"], :name => "ex_fundmts_01"

  create_table "ex_prices", :id => false, :force => true do |t|
    t.string "cid",      :limit => 6, :null => false
    t.string "sid",      :limit => 3, :null => false
    t.date   "datadate",              :null => false
    t.float  "csho"
    t.float  "ajex"
    t.float  "price"
    t.float  "volume"
    t.float  "pch1m"
    t.float  "pch3m"
    t.float  "pch6m"
    t.float  "pch9m"
    t.float  "pch12m"
  end

  add_index "ex_prices", ["cid", "sid", "datadate"], :name => "ex_price_ix01"

  create_table "ex_securities", :id => false, :force => true do |t|
    t.string  "cid",     :limit => 6,  :null => false
    t.string  "sid",     :limit => 3,  :null => false
    t.string  "cusip",   :limit => 9
    t.date    "dldtei"
    t.string  "dlrsni",  :limit => 8
    t.string  "dsci",    :limit => 28
    t.string  "epf",     :limit => 1
    t.integer "exchg",   :limit => 2
    t.string  "excntry", :limit => 3
    t.string  "ibtic",   :limit => 6
    t.string  "isin",    :limit => 12
    t.string  "secstat", :limit => 1
    t.string  "sedol",   :limit => 7
    t.string  "tic",     :limit => 20
    t.string  "tpci",    :limit => 8
    t.string  "name",    :limit => 64
    t.string  "ticker",  :limit => 20
  end

  add_index "ex_securities", ["cid", "sid"], :name => "ex_securities_ix01"
  add_index "ex_securities", ["tic"], :name => "ex_securities_ix03"
  add_index "ex_securities", ["ticker"], :name => "ex_securities_ix02"

  create_table "filters", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "search_actions", :force => true do |t|
    t.integer  "user_id"
    t.integer  "search_id"
    t.integer  "action_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "search_details", :force => true do |t|
    t.integer "search_id"
    t.string  "cid"
    t.string  "sid"
    t.date    "pricedate"
    t.float   "dist"
    t.float   "stk_rtn"
    t.float   "mrk_rtn"
  end

  add_index "search_details", ["search_id"], :name => "search_id"

  create_table "search_statuses", :force => true do |t|
    t.integer  "search_id"
    t.date     "fromdate"
    t.date     "thrudate"
    t.string   "comment"
    t.integer  "num_steps"
    t.integer  "cur_step"
    t.boolean  "complete"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "search_statuses", ["search_id", "fromdate", "thrudate"], :name => "search_statuses_uniq", :unique => true

  create_table "search_types", :force => true do |t|
    t.string   "factors"
    t.string   "weights"
    t.string   "gicslevel"
    t.string   "newflag"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "searches", :force => true do |t|
    t.string   "cid"
    t.string   "sid"
    t.date     "pricedate"
    t.date     "fromdate"
    t.date     "thrudate"
    t.integer  "type_id"
    t.integer  "count"
    t.integer  "wins"
    t.float    "mean"
    t.float    "max"
    t.float    "min"
    t.time     "sharedat"
    t.time     "savedat"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "users", :force => true do |t|
    t.integer  "role",          :null => false
    t.string   "provider",      :null => false
    t.string   "email",         :null => false
    t.string   "username",      :null => false
    t.string   "password_hash", :null => false
    t.string   "first_name"
    t.string   "last_name"
    t.string   "oauth_token"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

end
