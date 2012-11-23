# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
Investment.create(:ticker => 'MSFT', :name => 'Microsoft Corporation')
Investment.create(:ticker => 'AAPL', :name => 'Apple Computers')
Investment.create(:ticker => 'IBM', :name => 'International Business Machines')
Investment.create(:ticker => 'MNST', :name => 'Hansen International')
Investment.create(:ticker => 'GOOG', :name => 'Google Inc.')
Investment.create(:ticker => 'GME', :name => 'GameSpot International')
Investment.create(:ticker => 'CSCO', :name => 'Cisco Systems')
Investment.create(:ticker => 'CMG', :name => 'Chipotle Mexican Grill')
Investment.create(:ticker => 'PNRA', :name => 'Panera Bread Co.')