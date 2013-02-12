namespace :tests do

  desc "test"
  task :test1 => :environment do

    s1 = Search.create( :cid=>'300' , 
                        :sid=>'001' , 
                        :pricedate=> '2013-01-31',
                        :search_type=>'t1')

    puts s1.cid
    puts s1.id

  end

end
