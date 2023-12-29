should_seed_staging = !ENV["SHOULD_SEED_STAGING_DB"].nil? && Language.count == 0

seed_dir = File.join(Rails.root, 'db', 'seeds')

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
      require_relative 'seeds/searchgov_domain.rb'
    end
  rescue Errno::EADDRNOTAVAIL
    puts "Skipping i14yDrawer and SearchgovDomain seeds as there is no running I14y instance"
  rescue Errno::ECONNREFUSED
    puts "Skipping i14yDrawer and SearchgovDomain seeds as there is no running I14y instance"
  end
  puts 'Creating custom index data'
  Dir[File.join(seed_dir, 'custom_index_data', '*.rb')].each {|file| require file }
elsif Rails.env.test?
  puts 'Skipping seeds in test environment; specs should create their own data'
else
  puts "Cowardly refusing to run seeds in #{Rails.env} environment"
end
