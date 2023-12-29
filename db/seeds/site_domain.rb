# frozen_string_literal: true

# This supports seeding i14y/searchgov data for the searchgov_affiliate.
searchgov_affiliate = Affiliate.find_by(name: 'searchgov_affiliate')

puts "Creating Site Domain"

SiteDomain.create(affiliate_id: searchgov_affiliate.id, site_name: 'search.gov', domain: 'search.gov')