namespace :robots do

  # rake robots:search
  desc "Pre-run as many searches as possible!"
  task :search => :environment do
    
    date = "2013-03-01"

    count = 0
    
    snapshots = Array::new()

    SecuritySnapshot.each_snapshot_on( date ) { |s|

      count += 1
      snapshots.push(s)

    }

    snapshots.sort! { |a,b| 

      acap = a.get_field('mrkcap') || 0
      bcap = b.get_field('mrkcap') || 0
      bcap <=> acap

    }
    
    factor_keys = Factors::defaults
    weights     = Factors::default_weights
    epochs      = Epoch::default_epochs_array()
    gicslevel   = 'sec'

    search_type =
      SearchType::find_or_create(:factors   => factor_keys ,
                                 :weights   => weights     ,
                                 :gicslevel => gicslevel   ,
                                 :newflag   => 1           )
 
    snapshots.each { |target|

      name   = target.get_field('name')
      ticker = target.get_field('ticket')
      print "Executing search for on #{name} #{ticker} ..."
     
      Search::exec( :target      => target      ,
                    :epochs      => epochs      ,
                    :search_type => search_type ,
                    :limit       => 10          ,
                    :async       => false       )

      puts " done."

    }

  end

end
