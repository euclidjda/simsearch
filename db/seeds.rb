# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
Security.create(:ticker => 'MSFT', :name => 'Microsoft Corporation')
Security.create(:ticker => 'AAPL', :name => 'Apple Computers')
Security.create(:ticker => 'IBM', :name => 'International Business Machines')
Security.create(:ticker => 'MNST', :name => 'Hansen International')
Security.create(:ticker => 'GOOG', :name => 'Google Inc.')
Security.create(:ticker => 'GME', :name => 'GameSpot International')
Security.create(:ticker => 'CSCO', :name => 'Cisco Systems')
Security.create(:ticker => 'CMG', :name => 'Chipotle Mexican Grill')
Security.create(:ticker => 'PNRA', :name => 'Panera Bread Co.')