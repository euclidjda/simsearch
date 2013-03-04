class Epoch < Struct::new(:fromdate,:thrudate)
  def self.default_epochs_array
    [ Epoch.new( Date.parse('2000-01-01') ,Date.parse('2011-12-31') ),
      Epoch.new( Date.parse('1990-01-01') ,Date.parse('1999-12-31') ),
      Epoch.new( Date.parse('1980-01-01') ,Date.parse('1989-12-31') ),
      Epoch.new( Date.parse('1970-01-01') ,Date.parse('1979-12-31') ) ]
  end
end
