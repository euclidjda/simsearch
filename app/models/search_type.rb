class SearchType < ActiveRecord::Base
  attr_accessible :factors, :gicslevel, :newflag, :weights

  # Return the first object which matches the attributes hash
  # - or -
  # Create new object with the given attributes
  #
  def self.find_or_create(attributes)
    SearchType.where(attributes).first || SearchType.create(attributes)
  end

  # Serialize and un-serialize arrays for storing as keys
  def self.arr2key(arr) 
    arr.join(',')
  end

  def self.key2arr(key)
    key.split(',')
  end

end
