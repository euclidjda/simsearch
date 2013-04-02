namespace :cluster do

  desc "Export for graphlab. Do: rake cluster:export > data.txt"
  task :export => :environment do

    count = 0;

    Factors.each do |rec|

      factor_keys = rec.factor_keys
      
      factor_keys.each  do |key|
          
          factor = rec.get_factor(key)

          print( factor.nil? ? 'NULL ' : sprintf("%.8f ",factor) )

      end
      print "\n"
      STDOUT.flush
      
    end

  end

  desc "Import clusters from graphlab. Do: rake cluster:import < clusters.txt"
  task :import => :environment do
 
    # For each cluster

    read_cvectors.each do |cvector|

      center = Factors.nearest_neighbor( cvector )

      # 1. create center record with center_id

      Factors.each do | point |

        dist = center.distance( point )

        # 2. insert dist row for this center_id, point pair

      end

    end

  end

  def read_cvectors

    cvectors = Array::new

    STDIN.each_line do |line|

      cvectors.push(line.strip.split(/\s+/))

    end

    return cvectors

  end

end
