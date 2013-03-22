class SearchType < ActiveRecord::Base
  attr_accessible :factors, :gicslevel, :newflag, :weights

  # Return the first object which matches the attributes hash
  # - or -
  # Create new object with the given attributes
  #
  def self.find_or_create(attr)
    # These need to be serialized before they are compared and set
    attr[:factors] = attr[:factors].join(',')
    attr[:weights] = attr[:weights].join(',')

    SearchType.where(attr).first || SearchType.create(attr)
  end

  def factor_keys
    self.factors.split(",").map { |a| a.to_sym }
  end

  def weight_array
    self.weights.split(",").map { |a| a.to_f }
  end

end
