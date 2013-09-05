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
      attr_accessor :cid, :sid, :date, :ticker, :ey, :roic, 
                      :ey_rank, :roic_rank, :combined_rank,
                      :mrkcap

      def initialize(args)
        @date = args[:date]
        @cid = args[:cid]
        @sid = args[:sid]
        @ticker = args[:ticker]
        @ey = args[:ey]
        @roic = args[:roic]
        @mrkcap = args[:mrkcap]
      end

    end

    date = ExPrice.where("cid != 'SP0500'").maximum("datadate")

    puts date

    count = 0
    
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
          :mrkcap => s.get_field('mrkcap'))


        entries.push(entry)
      
        #puts "#{entry.ticker}, #{s.get_field('idxsec')}, #{s.get_field('idxind')} -- #{entry.ey} , #{entry.roic}"   
      end

    }

    #clean empty ey and roic value records.
    entries.keep_if { |a| a.ey.nil? || a.roic.nil? || a.mrkcap.nil?}
    puts "ticker, cid, sid, mrkcap, ey, roic" 
    entries.each { |e| 
      puts "#{e.ticker}, #{e.cid}, #{e.sid}, #{e.mrkcap}, #{e.ey}, #{e.roic}"
    }

    # entries.delete_if { |a| a.roic.nil? }

    # puts "***************** sort the array on :ey ****************"

    # entries.sort! { |a, b|  a.ey <=> b.ey }

    # count = 0;
    # entries.each { |entry|
    #   count += 1
    #   entry.ey_rank = count
    #   entry.combined_rank = entry.ey_rank

    #   #puts "#{entry.ticker} -- #{entry.ey_rank} : #{entry.ey}"
    # }

    # puts "***************** sort the array on :roic ****************"

    # entries.sort! { |a, b| a.roic <=> b.roic }

    # count = 0;
    # entries.each { |entry|
    #   count += 1
    #   entry.roic_rank = count
    #   entry.combined_rank += entry.roic_rank

    #   #puts "#{entry.ticker} -- #{entry.roic_rank} : #{entry.roic}"
    # }  

    # entries.sort! {|a,b| a.combined_rank <=> b.combined_rank }
    # entries.reverse!

    # entries.each { |entry|
    #   if !entry.mrkcap.nil? && entry.mrkcap > 500 
    #     puts "#{date}, #{entry.combined_rank}, #{entry.ticker}, #{entry.mrkcap}, #{entry.cid}, #{entry.sid}, #{entry.ey}, #{entry.roic}, #{entry.ey_rank}, #{entry.roic_rank}"
    #   end
    # }
  end

end
