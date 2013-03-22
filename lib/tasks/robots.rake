namespace :robots do

  # rake robots:search
  desc "Pre-run as many searches as possible!"
  task :search => :environment do
    
    date = "2013-03-01"

    count = 0
    
    snapshots = Array::new()

    SecuritySnapshot.each_snapshots_on( date ) { |s|

      count += 1
      snapshots.push(s)

    }

    snapshots.sort! { |a,b| 

      acap = a.get_field('mrkcap') || 0
      bcap = b.get_field('mrkcap') || 0
      bcap <=> acap

    }
    
    factors = [:ey,:roc,:grwth,:epscon,:ae,:mom]
    weights = [5,5,5,5,5,5]
    epochs = Epoch::default_epochs_array()
    gicslevel = 'sec'

    snapshots.each { |target|

      name   = target.get_field('name')
      ticker = target.get_field('ticket')
      print "Searching on #{name} #{ticker} ..."

      search_type =
      SearchType::find_or_create(:factors   => SearchType::arr2key(factors) ,
                                 :weights   => SearchType::arr2key(weights) ,
                                 :gicslevel => gicslevel                    ,
                                 :newflag   => 1                            )
      
      Search::exec( :target      => target      ,
                    :epochs      => epochs      ,
                    :search_type => search_type ,
                    :limit       => 10          ,
                    :async       => false       )

      puts " done."

    }

  end

end
