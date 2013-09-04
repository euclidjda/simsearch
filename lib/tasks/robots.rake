namespace :robots do

  # rake robots:search
  desc "Pre-run as many searches as possible!"
  task :search => :environment do
    
    # THIS SHOULD BE 'YESTERDAY'

    # date = "2013-03-01"
    date = ExPrice.where("cid != 'SP0500'").maximum("datadate")

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
    gicslevel   = 'sub'
    epochs      = Epoch::default_epochs_array()

    search_type =
      SearchType::find_or_create(:factors   => factor_keys ,
                                 :weights   => weights     ,
                                 :gicslevel => gicslevel   ,
                                 :newflag   => 1           )
 
    snapshots.each { |target|

      name   = target.get_field('name')
      ticker = target.get_field('ticket')
      print "Executing search for #{name} #{ticker} ..."
     
      Search::exec( :target      => target      ,
                    :epochs      => epochs      ,
                    :search_type => search_type ,
                    :limit       => 10          ,
                    :async       => false       )

      puts " done."

    }

  end

  # rake robots:force_cache
  desc "Attempt to force as much of ex_combined into cache as possible"
  task :force_cache => :environment do
    
    dates = ActiveRecord::Base
      .connection
      .select_all("SELECT pricedate FROM ex_combined "+
                  "GROUP BY pricedate "+
                  "ORDER BY pricedate DESC;")

    dates.each { |daterec|

      pricedate = daterec['pricedate'].to_s

      result = ActiveRecord::Base
        .connection
        .select_all("SELECT * FROM ex_combined "+
                    "WHERE pricedate = '#{pricedate}';") 

      count = 0

      result.each { |record|

        count += 1

      }

      puts "#{pricedate} #{count}"

    }

  end

  # rake robots:greenblatt_daily
  task :greenblatt_daily => :environment do

    class GreenblattEntry
      attr_accessor :cid, :sid, :date, :ticker, :ey, :roic, :ey_rank, :roic_rank, :combined_rank

      def initialize(args)
        @date = args[:date]
        @cid = args[:cid]
        @sid = args[:sid]
        @ticker = args[:ticker]
        @ey = args[:ey]
        @roic = args[:roic]
      end

    end

    date = ExPrice.where("cid != 'SP0500'").maximum("datadate")

    puts date

    count = 0
    
    entries = Array::new()

    SecuritySnapshot.each_snapshot_on( date ) { |s|

      count += 1

      entry = GreenblattEntry.new(:date => date,
        :cid => s.cid, 
        :sid => s.sid, 
        :ticker => s.get_field('ticker'),
        :ey => s.get_factor(:ey),
        :roic => s.get_factor(:roic))


      entries.push(entry)
    
      puts "#{entry.ticker} -- #{entry.ey} , #{entry.roic}"   

    }



  end

end
