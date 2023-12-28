searchgov_affiliate = Affiliate.find_by(name: 'searchgov_affiliate')

puts "Creating Site Domain"

SiteDomain.create(affiliate_id: searchgov_affiliate.id, site_name: 'search.gov', domain: 'search.gov')