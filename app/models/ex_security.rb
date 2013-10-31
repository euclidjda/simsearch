class ExSecurity < ActiveRecord::Base

  def to_s
    "cid:#{cid}, sid:#{sid}, ticker:#{ticker}, name:#{name}"
  end

  def self.find_by_ticker(_t)
    ExSecurity.where(" ticker = '#{_t}' AND dldtei IS NULL").first
  end 

  def self.find_by_cidsid(_c, _s)
    ExSecurity.where(:cid => _c, :sid => _s).first
  end



end # class ExSecurity
