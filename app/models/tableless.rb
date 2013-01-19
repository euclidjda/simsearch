class Tableless < ActiveRecord::Base
  def self.columns
    @columns ||= [];
  end

  def self.column(_name, _sql_type = nil, _default = nil, _null = true)
    columns << ActiveRecord::ConnectionAdapters::Column.new(_name.to_s, 
                                                            _default, 
                                                            _sql_type.to_s, 
                                                            _null)
  end

  # Override the save method to prevent exceptions.
  def save(_validate = true)
    _validate ? valid? : true
  end
end
