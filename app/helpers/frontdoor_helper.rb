module FrontdoorHelper

  @@startDates =  { 
    :oughts    => '2000-01-01',
    :nineties  => '1990-01-01' ,
    :eighties  => '1980-01-01' ,
    :seventies => '1970-01-01' }
  
  @@endDates= { 
    :oughts    => '2011-12-31' ,
    :nineties  => '1999-12-31' ,
    :eighties  => '1989-12-31' ,
    :seventies => '1979-12-31' }

  def self.epochs
    [:oughts,:nineties,:eighties,:seventies]
  end

  def self.startDate(_epoch)
    @@startDates[_epoch]
  end

  def self.endDate(_epoch)
    @@endDates[_epoch]
  end

  # TODO: JDA: This is here temporarily until we display
  # by epoch in the view
  def self.collapseEpochs(_c) # c = comparables
    _c[:oughts] + _c[:nineties] + _c[:eighties] + _c[:seventies]
  end

end
