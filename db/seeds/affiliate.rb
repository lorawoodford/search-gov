# frozen_string_literal: true

Affiliate.create(name: 'test_affiliate', display_name: 'Test Affiliate')
Affiliate.create(name: 'spanish_affiliate', display_name: 'Test Spanish Affiliate', locale: 'es')
Affiliate.create(name: 'searchgov_affiliate', display_name: 'SearchGov Affiliate', search_engine: 'SearchGov')
