class Security < ActiveRecord::Base
  attr_accessible :name, :ticker, :cid, :sid
end
