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
    
    factor_keys = Defaults::factors
    weights     = Defaults::weights
    gicslevel   = Defaults::gicslevel
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
      attr_accessor :cid, :sid, :date, :ticker, :ey, :roic, 
                      :ey_rank, :roic_rank, :combined_rank,
                      :inv_cap,
                      :mrkcap

      def initialize(args)
        @date = args[:date]
        @cid = args[:cid]
        @sid = args[:sid]
        @ticker = args[:ticker]
        @ey = args[:ey]
        @roic = args[:roic]
        @mrkcap = args[:mrkcap]
        @inv_cap = args[:inv_cap]
      end

    end

    date = ExPrice.where("cid != 'SP0500'").maximum("datadate")

    puts date

    count = 0
    err_count = 0

    entries = Array::new()

    SecuritySnapshot.each_snapshot_on( date ) { |s|

      # Exclude financials and utilities.
      gics_sector = s.get_field('idxsec')

      if !(%w(40 55).include? gics_sector) 

        count += 1

        entry = GreenblattEntry.new(:date => date,
          :cid => s.cid, 
          :sid => s.sid, 
          :ticker => s.get_field('ticker'),
          :ey => s.get_factor(:ey),
          :roic => s.get_factor(:roic),
          :inv_cap => s.get_factor(:inv_cap),
          :mrkcap => s.get_field('mrkcap'))

        entries.push(entry)
      
        if s.get_field('oiadpq_ttm').nil? && entry.inv_cap > 0
          err_count += 1
          # puts "Alarm ==> #{entry.ticker} : EBIT is nil #{err_count}"
        end
      end

    }

    entries.each { |entry|
      # cleanup for ROIC
      if entry.roic.nil?
        # in case this is because of negative invested capital, set the roic to 100%.
        entry.roic = 1 if entry.inv_cap <= 0
      else
        # cap at 100%
        entry.roic = 1 if entry.roic > 1
      end
    }

    # remove records still without any ROIC on them.
    entries.delete_if { |e| e.roic.nil? }

    # sort based on ROIC (sorts small to large, so 1s are at the bottom, this is reverse order)
    entries.sort! { |a, b| a.roic <=> b.roic }

    count = 1
    entries.reverse_each { |entry| 

      if entry.roic == 1
        entry.roic_rank = 1
      else
        count += 1
        entry.roic_rank = count
      end

      entry.combined_rank = entry.roic_rank
    }

    # Are there any empty EY values ? remove them...
    entries.delete_if { |e| e.ey.nil? }

    # puts "*** Sorting the array on :ey to get rankings"
    entries.sort! { |a, b|  a.ey <=> b.ey }

    count = 0;
    entries.reverse_each { |entry|
      count += 1
      entry.ey_rank = count
      entry.combined_rank += entry.ey_rank

    }

    # sort on combined rank

    entries.sort! { |a, b| a.combined_rank <=> b.combined_rank }
    entries.reverse!

    printf "%8s | %-8s | %24s | %24s | %24s | %24s\n", 
            "Rank", "TICKER", "ROIC", "INV_CAP", "EY", "MRKCAP"
    entries.each { |entry| 

      if (entry.mrkcap.to_i > 500 ) 
        printf "%8s | %-8s | %24s | %24s | %24s | %24s\n", 
            entry.combined_rank, entry.ticker, entry.roic, entry.inv_cap, entry.ey, entry.mrkcap
      end
    }

    # # Print the .CSV file header line first.
    # puts "date, combined_rank, ticker, mrkcap, cid, sid, ey, roic, ey_rank, roic_rank"

    # entries.each { |entry|
    #   if entry.mrkcap > 500 
    #     puts "#{date}, #{entry.combined_rank}, #{entry.ticker}, #{entry.mrkcap}, #{entry.cid}, #{entry.sid}, #{entry.ey}, #{entry.roic}, #{entry.ey_rank}, #{entry.roic_rank}"
    #   end
    # }
  end

end
