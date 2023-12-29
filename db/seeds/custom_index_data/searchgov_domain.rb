# frozen_string_literal: true

# Note: I14y must be up (either locally or on staging) in order for the Searchgov Domain to be seeded.
# After seeding the database, you should see search results from the Searchgov index for this affiiate:
# /search?affiliate=searchgov_affiliate&sort_by=&query=roadmap

puts "Creating SearchgovDomain"

SearchgovDomain.create(domain: 'search.gov')