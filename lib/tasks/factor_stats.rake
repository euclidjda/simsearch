namespace :factor_stats do

  # rake factor_stats:sample date='2013-03-01'
  desc "Sample all factor values on specific date"
  task :sample => :environment  do
    
    date = ENV['date']

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

    
    factor_keys = Factors.all.map { |a| a[1] }

    row_str = factor_keys.join(",")
    puts row_str

    (0..1000).each { |index|

      cur = snapshots[index]

      values = Array.new()

      factor_keys.each { |key|

        value = cur.get_factor(key)

        if value.nil?
          values.push(" ")
        else
          values.push(sprintf "%.4f",value)
        end

      }
      
      row_str = values.join(",")
      puts row_str

    }

  end

end
