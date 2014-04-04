namespace :magicformula do |variable|
  #rake magicformula:retrieve
  desc "Retrieve most recent magicformula stock list."

  task :retrieve => :environment do

    require 'net/http'
    require 'uri'
    require 'nokogiri'

    url = URI.parse('http://magicformulainvesting.com/Account/LogOn')

    req = Net::HTTP::Post.new(url.path)
    req.set_form_data({'Email' => 'ferhane@gmail.com', 'Password' => 'magicfund', 'login' => 'Login'})
    resp = Net::HTTP.new(url.host, url.port).start {|http| http.request(req) }


    if resp.code != "302" || resp.message != "Found"
      puts "Login failed."
      puts "#{resp.code} : #{resp.message}"
      next
    end

    cookie = resp.response['set-cookie'].split(';')[0]

    # retrieve actual content
    url = URI.parse('http://magicformulainvesting.com/Screening/StockScreening')
    http = Net::HTTP.new(url.host, url.port)

    data = 'MinimumMarketCap=500&Select30=false&stocks=Get+Stocks'
    headers = {
      'Cookie' => cookie,
      'Content-Type' => 'application/x-www-form-urlencoded'
    }

    resp = http.post(url.path, data, headers)

    if resp.code != "200" 
      puts "Content retrieval failed"
      puts "#{resp.code} : #{resp.message}"
    end

    # First load the text into html, so we don't have to deal with strings for search
    doc = Nokogiri::HTML(resp.body)
    tbody = doc.search("//tbody")

    tbody.children.each do |tr|
      if tr.name == "tr"
        tr.children.each do |td|
          if td.name == "td"
            puts td.text
          end
        end
      end
    end
  end
end