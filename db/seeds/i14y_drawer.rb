# frozen_string_literal: true

# Note: I14y must be up (either locally or on staging) in order for the I14yDrawer to be created.

puts "Creating I14y Drawer"

I14yDrawer.create(handle: 'searchgov', description: 'drawer containing documents for the Search.gov search engine')