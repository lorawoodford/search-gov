require 'spec_helper'

describe AzureFormattedQuery do
  it 'strips site: and -site:' do
    query = AzureFormattedQuery.new(' site:foo.com  gov  -site:bar.com ')
    expect(query.query).to eq('gov (site:gov OR site:mil)')
  end

  context 'when included domains is present' do
    it 'generates query with those included domains' do
      query = AzureFormattedQuery.new('gov', included_domains: %w(foo.com bar.com))
      expect(query.query).to eq('gov (site:bar.com OR site:foo.com)')
    end
  end

  context 'when scope_ids are provided' do
    it 'generates query with scopeids as well as domains' do
      query = AzureFormattedQuery.new('gov', scope_ids: %w(inherit the wind), included_domains: %w(foo.com bar.com))
      expect(query.query).to eq('gov (scopeid:wind OR scopeid:the OR scopeid:inherit OR site:bar.com OR site:foo.com)')
    end
  end

  context 'when included domains is not present' do
    it 'generates query with default domains' do
      query = AzureFormattedQuery.new('gov', included_domains: [])
      expect(query.query).to eq('gov (site:gov OR site:mil)')
    end
  end

  context 'when excluded domains are present' do
    it 'generates query with those excluded domains' do
      query = AzureFormattedQuery.new('gov', excluded_domains: %w(exfoo.com exbar.com))
      expect(query.query).to eq('gov (site:gov OR site:mil) -site:exbar.com -site:exfoo.com')
    end
  end

  context 'when included and excluded domains are present' do
    it 'generates query with included and excluded domains' do
      query = AzureFormattedQuery.new('gov',
                                      excluded_domains: %w(exfoo.com exbar.com),
                                      included_domains: %w(foo.com bar.com))
      expect(query.query).to eq('gov (site:bar.com OR site:foo.com) -site:exbar.com -site:exfoo.com')
    end
  end

  it 'downcases the query' do
    query =  AzureFormattedQuery.new('Egypt').query
    expect(query).to match /egypt/
  end

  context 'when the query includes search operators' do
    let(:query_with_operators) { 'Egypt OR Morocco' }

    it 'preserves the case of search operators' do
      query = AzureFormattedQuery.new(query_with_operators).query
      expect(query).to match /egypt OR morocco/
    end
  end
end
