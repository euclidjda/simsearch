namespace :test do

  # rake test:example_with_args['hello world']
  desc "Example with environment and variables"
  task :example_with_args, [:message]  => :environment  do |t, args|

    args.with_defaults(:message => "Thanks for logging on")

    puts "Message: #{args.message}" 
  end

  # rake test:example_with_env message='hello world'
  desc "Example with environmental variables"
  task :example_with_env => :environment  do

    puts "Message: #{ENV['message']}" 
  end

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
