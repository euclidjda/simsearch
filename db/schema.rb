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

ActiveRecord::Schema.define(:version => 20121202082420) do

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
    t.integer "idxind",                     :null => false
    t.integer "idxdiv",                     :null => false
    t.integer "idxnew",                     :null => false
    t.integer "idxcapl",                    :null => false
    t.integer "idxcaph",                    :null => false
    t.integer "idxvall",                    :null => false
    t.integer "idxvalh",                    :null => false
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
    t.float   "atq_mrq"
    t.float   "dlttq_mrq"
    t.float   "dlcq_mrq"
    t.float   "pstkq_mrq"
    t.float   "mibnq_mrq"
    t.float   "mibq_mrq"
  end

  add_index "ex_factdata", ["cid", "sid", "fromdate", "thrudate"], :name => "ex_factdata_ix01"
  add_index "ex_factdata", ["idxind", "idxdiv", "idxnew", "idxcapl", "idxcaph", "idxvall", "idxvalh"], :name => "ex_factdata_ix02"

  create_table "ex_fundmts", :id => false, :force => true do |t|
    t.string "cid",      :limit => 6, :null => false
    t.date   "fromdate",              :null => false
    t.date   "thrudate",              :null => false
    t.date   "datadate",              :null => false
    t.string "type",     :limit => 3, :null => false
    t.float  "sale"
    t.float  "cogs"
    t.float  "gross"
    t.float  "xsgna"
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
    t.float  "fcfl"
  end

  add_index "ex_fundmts", ["cid", "fromdate", "thrudate", "type"], :name => "ex_funddata_01"

  create_table "ex_prices", :id => false, :force => true do |t|
    t.string "cid",      :limit => 6, :null => false
    t.string "sid",      :limit => 3, :null => false
    t.date   "datadate",              :null => false
    t.float  "csho"
    t.float  "ajex"
    t.float  "price"
    t.float  "pch1m"
    t.float  "pch3m"
    t.float  "pch6m"
    t.float  "pch9m"
    t.float  "pch12m"
  end

  add_index "ex_prices", ["cid", "sid", "datadate"], :name => "ex_price_ix01"

  create_table "filters", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "securities", :id => false, :force => true do |t|
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

  add_index "securities", ["cid", "sid"], :name => "securities_ix01"
  add_index "securities", ["tic"], :name => "securities_ix03"
  add_index "securities", ["ticker"], :name => "securities_ix02"

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
