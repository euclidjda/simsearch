namespace :search do

  desc "Execute a search"
  task :exec => :environment  do

    _search_id  = ENV['search_id']
    _limit      = ENV['limit']

    puts("***** logging from with search:exec #{_search_id} #{_limit}")

    # TODO: Assert all values above

    search = Search.where( :id => _search_id ).first

    target = SecuritySnapshot::get_snapshot(search.cid,search.sid,search.pricedate)
    
    candidates = Array::new()

    target.each_match( search.fromdate, search.thrudate ) { |match|

      dist = target.distance( match )
      next if (dist < 0)
      candidates.push( { :match => match, :dist => dist } )

    }

    # debug info line here to make sure we are rendering the right number on screen.
    puts "********** #{candidates.length}   ***********"

    search.completed = 1
    search.save()

  end

end
