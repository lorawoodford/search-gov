should_seed_staging = !ENV["SHOULD_SEED_STAGING_DB"].nil? && Language.count == 0

# This includes minimal data. Additional seeds will be added per SRCH-2521
if Rails.env.development? || should_seed_staging
  require_relative 'seeds/agency.rb'
  require_relative 'seeds/language.rb'
  require_relative 'seeds/affiliate.rb'
  require_relative 'seeds/site_domain.rb'
  require_relative 'seeds/email_template.rb'
  require_relative 'seeds/search_module.rb'
  begin
    if Net::HTTP.get_response(URI.parse(I14y.host)).code == '200'
      require_relative 'seeds/i14y_drawer.rb'
      require_relative 'seeds/custom_index_data/searchgov_domain.rb'
    end
  rescue Errno::EADDRNOTAVAIL, Errno::ECONNREFUSED
    puts "Skipping i14yDrawer and SearchgovDomain seeds as there is no running I14y instance"
  end
  # To allow db:seed to be run multiple times (e.g. running again after standing up the API instance
  # in staging and seeded I14y content), ensure we're skipping seeding index data that already exists.
  require_relative 'seeds/custom_index_data/news.rb' if RssFeed.find_by(name: 'News') == nil
  require_relative 'seeds/custom_index_data/videos.rb' if RssFeed.find_by(name: 'Videos') == nil
elsif Rails.env.test?
  puts 'Skipping seeds in test environment; specs should create their own data'
else
  puts "Cowardly refusing to run seeds in #{Rails.env} environment"
end
