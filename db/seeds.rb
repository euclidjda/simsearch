# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
User.create(:provider => "manual", :email => "ferhane@gmail.com", :role => 1)
User.create(:provider => "manual", :email => "john.alberg@euclidean.com", :role => 1)
Security.create(:ticker => 'MSFT', :name => 'Microsoft Corporation')
Security.create(:ticker => 'AAPL', :name => 'Apple Computers')
Security.create(:ticker => 'IBM', :name => 'International Business Machines')
Security.create(:ticker => 'MNST', :name => 'Hansen International')
Security.create(:ticker => 'GOOG', :name => 'Google Inc.')
Security.create(:ticker => 'GME', :name => 'GameSpot International')
Security.create(:ticker => 'CSCO', :name => 'Cisco Systems')
Security.create(:ticker => 'CMG', :name => 'Chipotle Mexican Grill')
Security.create(:ticker => 'PNRA', :name => 'Panera Bread Co.')
Filter.create(:name => ':DBEG', :description => 'Beginning date of date range')
Filter.create(:name => ':DEND', :description => 'Ending date of date range')
Filter.create(:name => ':EPS', :description => 'Give EPS similarity priority')
Filter.create(:name => ':MACRO', :description => 'Only show matches that are from similar macroeconomic periods')
Filter.create(:name => ':DIV', :description => 'Give priority matching to dividend stocks')
Filter.create(:name => ':IPO', :description => 'Show IPO stocks only')
Filter.create(:name => ':NQ', :description => 'Specific number of quarters to go back in history')
Filter.create(:name => ':NCY', :description => 'Specific number of calendar years to go back in history')


