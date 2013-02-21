namespace :search do

  desc "Execute a search"
  task :exec => :environment  do

    _search_id  = ENV['search_id']
    _limit      = ENV['limit']

    puts("***** logging from with search:exec #{_search_id} #{_limit}")

    # TODO: Assert all values above

    search = Search.where( :id => _search_id ).first

    sleep(3)

    search.completed = 1
    search.save()

  end

end
