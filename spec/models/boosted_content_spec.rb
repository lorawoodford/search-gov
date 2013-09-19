require 'spec_helper'

describe BoostedContent do
  fixtures :affiliates
  before do
    @affiliate = affiliates(:usagov_affiliate)
    @valid_attributes = {
      :affiliate => @affiliate,
      :url => "http://www.someaffiliate.gov/foobar",
      :title => "The foobar page",
      :description => "All about foobar, boosted to the top",
      :status => 'active',
      :publish_start_on => Date.yesterday
    }
  end

  describe "Creating new instance of BoostedContent" do
    it { should validate_presence_of :url }
    it { should validate_presence_of :title }
    it { should validate_presence_of :description }
    it { should validate_presence_of :affiliate }
    it { should validate_presence_of :publish_start_on }

    BoostedContent::STATUSES.each do |status|
      it { should allow_value(status).for(:status) }
    end
    it { should_not allow_value("bogus status").for(:status) }

    specify { BoostedContent.new(:status => 'active').should be_is_active }
    specify { BoostedContent.new(:status => 'active').should_not be_is_inactive }
    specify { BoostedContent.new(:status => 'inactive').should be_is_inactive }
    specify { BoostedContent.new(:status => 'inactive').should_not be_is_active }

    it { should belong_to :affiliate }
    it { should have_many(:boosted_content_keywords).dependent(:destroy) }

    it "should create a new instance given valid attributes" do
      BoostedContent.create!(@valid_attributes)
    end

    it "should validate unique url" do
      BoostedContent.create!(@valid_attributes)
      duplicate = BoostedContent.new(@valid_attributes.merge(:url => @valid_attributes[:url].upcase))
      duplicate.should_not be_valid
      duplicate.errors[:url].first.should =~ /already been boosted/
    end

    it "should allow a duplicate url for a different affiliate" do
      BoostedContent.create!(@valid_attributes)
      duplicate = BoostedContent.new(@valid_attributes.merge(:affiliate => affiliates(:basic_affiliate)))
      duplicate.should be_valid
    end

    it "should not allow publish start date before publish end date" do
      boosted_content = BoostedContent.create(@valid_attributes.merge({ :publish_start_on => '07/01/2012', :publish_end_on => '07/01/2011' }))
      boosted_content.errors.full_messages.join.should =~ /Publish end date can't be before publish start date/
    end

    it "should save URL with http:// prefix when it does not start with http(s)://" do
      url = 'usasearch.howto.gov/post/9866782725/did-you-mean-roes-or-rose'
      prefixes = %w( http https invalidHtTp:// invalidhttps:// invalidHttPsS://)
      prefixes.each do |prefix|
        boosted_content = BoostedContent.create!(@valid_attributes.merge(:url => "#{prefix}#{url}"))
        boosted_content.url.should == "http://#{prefix}#{url}"
      end
    end

    it "should save URL as is when it starts with http(s)://" do
      url = 'usasearch.howto.gov/post/9866782725/did-you-mean-roes-or-rose'
      prefixes = %w( http:// HTTPS:// )
      prefixes.each do |prefix|
        boosted_content = BoostedContent.create!(@valid_attributes.merge(:url => "#{prefix}#{url}"))
        boosted_content.url.should == "#{prefix}#{url}"
      end
    end
  end

  describe ".recent" do
    it "should include a scope called 'recent'" do
      BoostedContent.recent.should_not be_nil
    end
  end

  describe "#human_attribute_name" do
    specify { BoostedContent.human_attribute_name("publish_start_on").should == "Publish start date" }
    specify { BoostedContent.human_attribute_name("publish_end_on").should == "Publish end date" }
    specify { BoostedContent.human_attribute_name("url").should == "URL" }
  end

  describe "#as_json" do
    it "should include title, url, and description" do
      hash = BoostedContent.create!(@valid_attributes).as_json
      hash[:title].should == @valid_attributes[:title]
      hash[:url].should == @valid_attributes[:url]
      hash[:description].should == @valid_attributes[:description]
      hash.keys.length.should == 3
    end
  end

  describe "#to_xml" do
    it "should include title, url, and description" do
      hash = Hash.from_xml(BoostedContent.create!(@valid_attributes).to_xml)['boosted_result']
      hash['title'].should == @valid_attributes[:title]
      hash['url'].should == @valid_attributes[:url]
      hash['description'].should == @valid_attributes[:description]
      hash.keys.length.should == 3
    end
  end

  context "when the affiliate associated with a particular Boosted Content is destroyed" do
    before do
      affiliate = Affiliate.create!({:display_name => "Test Affiliate", :name => 'test_affiliate'}, :as => :test)
      BoostedContent.create(@valid_attributes.merge(:affiliate => affiliate))
      affiliate.destroy
    end

    it "should also delete the boosted Content" do
      BoostedContent.find_by_url(@valid_attributes[:url]).should be_nil
    end
  end

  describe ".process_boosted_content_bulk_upload_for" do
    context "when uploading xml file" do
      let(:affiliate) { affiliates(:basic_affiliate) }
      let(:xml_file) { mock('xml_file', { :original_filename => "boosted_content.xml" }) }

      before do
        BoostedContent.should_receive(:process_boosted_content_xml_upload_for).with(affiliate, xml_file).and_return({ :success => true, :created => 1, :updated => 0 })
        @results = BoostedContent.bulk_upload(affiliate, xml_file)
      end

      subject { @results }
      specify { @results[:success].should be_true }
      specify { @results[:created].should == 1 }
      specify { @results[:updated].should == 0 }
    end

    context "when the uploaded file has text/csv content type" do
      let(:affiliate) { affiliates(:basic_affiliate) }
      let(:csv_file) { mock('csv_file', { :original_filename => 'boosted_content.csv' }) }

      before do
        BoostedContent.should_receive(:process_boosted_content_csv_upload_for).with(affiliate, csv_file).and_return({ :success => true, :created => 1, :updated => 0 })
        @results = BoostedContent.bulk_upload(affiliate, csv_file)
      end

      subject { @results }
      specify { @results[:success].should be_true }
      specify { @results[:created].should == 1 }
      specify { @results[:updated].should == 0 }
    end

    context "when the uploaded file has .txt extension" do
      let(:affiliate) { affiliates(:basic_affiliate) }
      let(:txt_file) { mock('txt_file', { :original_filename => "boosted_content.txt" }) }

      before do
        BoostedContent.should_receive(:process_boosted_content_csv_upload_for).with(affiliate, txt_file).and_return({ :success => true, :created => 1, :updated => 0 })
        @results = BoostedContent.bulk_upload(affiliate, txt_file)
      end

      subject { @results }
      specify { @results[:success].should be_true }
      specify { @results[:created].should == 1 }
      specify { @results[:updated].should == 0 }
    end

    context "when the uploaded file has .png extension" do
      let(:affiliate) { affiliates(:basic_affiliate) }
      let(:png_file) { mock('png_file', { :original_filename => "boosted_content.png" }) }

      before do
        @results = BoostedContent.bulk_upload(affiliate, png_file)
      end

      subject { @results }
      specify { @results[:success].should be_false }
    end

    context "when the bulk upload file parameter is nil" do
      let(:affiliate) { affiliates(:basic_affiliate) }

      before do
        @results = BoostedContent.bulk_upload(affiliate, nil)
      end

      subject { @results }
      specify { @results[:success].should be_false }
    end
  end

  describe ".process_boosted_content_xml_upload_for" do
    let(:site_xml) {
      <<-XML
        <xml>
          <entries>
            <entry>
              <title>This is a listing about Texas</title>
              <url>http://some.url</url>
              <description>This is the description of the listing</description>
            </entry>
            <entry>
              <title>Some other listing about hurricanes</title>
              <url>http://some.other.url</url>
              <description>Another description for another listing</description>
            </entry>
          </entries>
        </xml>
      XML
    }

    let(:basic_affiliate) { affiliates(:basic_affiliate) }

    before do
      basic_affiliate.boosted_contents.destroy_all
      BoostedContent.reindex
      Sunspot.commit
    end

    it "should create and index boosted Contents from an xml document" do
      results = BoostedContent.process_boosted_content_xml_upload_for(basic_affiliate, StringIO.new(site_xml))
      Sunspot.commit

      basic_affiliate.reload
      basic_affiliate.boosted_contents.length.should == 2
      basic_affiliate.boosted_contents.map(&:url).should =~ %w{http://some.url http://some.other.url}
      basic_affiliate.boosted_contents.all.find { |b| b.url == "http://some.other.url" }.description.should == "Another description for another listing"
      BoostedContent.solr_search_ids { with :affiliate_id, basic_affiliate.id; paginate(:page => 1, :per_page => 10) }.should =~ basic_affiliate.boosted_content_ids
      results[:success].should be_true
      results[:created].should == 2
      results[:updated].should == 0
    end

    it "should update existing boosted Contents if the url match" do
      basic_affiliate.boosted_contents.create!(:url => "http://some.url", :title => "an old title", :description => "an old description", :status => 'active', :publish_start_on => Date.current)
      results = BoostedContent.process_boosted_content_xml_upload_for(basic_affiliate, StringIO.new(site_xml))
      Sunspot.commit

      basic_affiliate.reload
      basic_affiliate.boosted_contents.length.should == 2
      basic_affiliate.boosted_contents.all.find { |b| b.url == "http://some.url" }.title.should == "This is a listing about Texas"
      results[:success].should be_true
      results[:created].should == 1
      results[:updated].should == 1
    end

    it "should merge with preexisting boosted Contents" do
      basic_affiliate.boosted_contents.create!(:url => "http://a.different.url", :title => "title", :description => "description", :publish_start_on => Date.current, :status => 'active')
      results = BoostedContent.process_boosted_content_xml_upload_for(basic_affiliate, StringIO.new(site_xml))
      Sunspot.commit

      basic_affiliate.reload
      basic_affiliate.boosted_contents.length.should == 3
      basic_affiliate.boosted_contents.map(&:url).should =~ %w{http://some.url http://some.other.url http://a.different.url}
      results[:success].should be_true
      results[:created].should == 2
      results[:updated].should == 0
    end

    it "should not update existing boosted Contents if one of the imports failed" do
      basic_affiliate.boosted_contents.create!(:url => "http://some.other.url", :title => "an old title", :description => "an old description", :status => 'active', :publish_start_on => Date.current)
      BoostedContent.reindex
      Sunspot.commit
      bc = BoostedContent.new(:title => 'This is a listing about Texas',
                              :url => 'http://some.url',
                              :description => 'This is the description of the listing',
                              :status => 'active', :publish_start_on => Date.current)

      BoostedContent.should_receive(:find_or_initialize_by_url).with(hash_including(:url => 'http://some.url')).and_return(bc)

      BoostedContent.should_receive(:find_or_initialize_by_url).with(hash_including(:url => 'http://some.other.url')).
        and_raise(ActiveRecord::RecordInvalid.new(bc))

      results = BoostedContent.process_boosted_content_xml_upload_for(basic_affiliate, StringIO.new(site_xml))
      Sunspot.commit

      results[:success].should be_false
      basic_affiliate.reload
      basic_affiliate.boosted_contents.length.should == 1
      basic_affiliate.boosted_contents.all.find { |b| b.url == "http://some.other.url" }.title.should == "an old title"
      BoostedContent.solr_search_ids { with :affiliate_id, basic_affiliate.id; paginate(:page => 1, :per_page => 10) }.length.should == 1
    end
  end

  describe ".process_boosted_content_csv_upload_for" do
    let(:csv_file) {
      <<-CSV
This is a listing about Texas,http://some.url,This is the description of the listing

Some other listing about hurricanes,http://some.other.url,Another description for another listing

      CSV
    }

    let(:basic_affiliate) { affiliates(:basic_affiliate) }

    before do
      basic_affiliate.boosted_contents.destroy_all
      BoostedContent.reindex
      Sunspot.commit
    end

    it "should create and index boosted Contents from an csv document" do
      results = BoostedContent.process_boosted_content_csv_upload_for(basic_affiliate, StringIO.new(csv_file))
      Sunspot.commit

      basic_affiliate.reload
      basic_affiliate.boosted_contents.length.should == 2
      basic_affiliate.boosted_contents.map(&:url).should =~ %w{http://some.url http://some.other.url}
      basic_affiliate.boosted_contents.all.find { |b| b.url == "http://some.other.url" }.description.should == "Another description for another listing"
      BoostedContent.solr_search_ids { with :affiliate_id, basic_affiliate.id; paginate(:page => 1, :per_page => 10) }.should =~ basic_affiliate.boosted_content_ids
      results[:success].should be_true
      results[:created].should == 2
      results[:updated].should == 0
    end

    it "should update existing boosted Contents if the url match" do
      basic_affiliate.boosted_contents.create!(:url => "http://some.url", :title => "an old title", :description => "an old description", :status => 'active', :publish_start_on => Date.current)

      results = BoostedContent.process_boosted_content_csv_upload_for(basic_affiliate, StringIO.new(csv_file))

      basic_affiliate.reload
      basic_affiliate.boosted_contents.length.should == 2
      basic_affiliate.boosted_contents.all.find { |b| b.url == "http://some.url" }.title.should == "This is a listing about Texas"
      results[:success].should be_true
      results[:created].should == 1
      results[:updated].should == 1
    end

    it "should merge with preexisting boosted Contents" do
      basic_affiliate.boosted_contents.create!(:url => "http://a.different.url", :title => "title", :description => "description", :status => 'active', :publish_start_on => Date.current)

      results = BoostedContent.process_boosted_content_csv_upload_for(basic_affiliate, StringIO.new(csv_file))

      basic_affiliate.reload
      basic_affiliate.boosted_contents.length.should == 3
      basic_affiliate.boosted_contents.map(&:url).should =~ %w{http://some.url http://some.other.url http://a.different.url}
      results[:success].should be_true
      results[:created].should == 2
      results[:updated].should == 0
    end

    it "should not update existing boosted Contents if one of the imports failed" do
      basic_affiliate.boosted_contents.create!(:url => "http://some.other.url", :title => "an old title", :description => "an old description", :status => 'active', :publish_start_on => Date.current)
      bc = BoostedContent.new(:title => 'This is a listing about Texas',
                              :url => 'http://some.url',
                              :description => 'This is the description of the listing',
                              :status => 'active', :publish_start_on => Date.current)
      BoostedContent.should_receive(:find_or_initialize_by_url).with(hash_including(:url => 'http://some.url')).and_return(bc)

      BoostedContent.should_receive(:find_or_initialize_by_url).with(hash_including(:url => 'http://some.other.url')).
        and_raise(ActiveRecord::RecordInvalid.new(bc))

      results = BoostedContent.process_boosted_content_csv_upload_for(basic_affiliate, StringIO.new(csv_file))

      results[:success].should be_false
      basic_affiliate.reload
      basic_affiliate.boosted_contents.length.should == 1
      basic_affiliate.boosted_contents.all.find { |b| b.url == "http://some.other.url" }.title.should == "an old title"
    end
  end

  describe "#search_for" do
    context "when the term is not mentioned in the description" do
      before do
        @boosted_content = BoostedContent.new(@valid_attributes)
        @boosted_content.boosted_content_keywords.build(:value => 'pollution')
        @boosted_content.save!
        BoostedContent.reindex
        Sunspot.commit
      end

      it "should find a boosted content by keyword" do
        search = BoostedContent.search_for('pollute', @affiliate)
        search.total.should == 1
        search.results.first.should == @boosted_content
      end
    end

    context "when the affiliate is specified" do
      it "should instrument the call to Solr with the proper action.service namespace, affiliate, and query param hash" do
        ActiveSupport::Notifications.should_receive(:instrument).
          with("solr_search.usasearch", hash_including(:query => hash_including(:affiliate => @affiliate.name, :model=>"BoostedContent", :term => "foo")))
        BoostedContent.search_for('foo', @affiliate)
      end
    end

    context "when the Boosted Content is in English" do
      before do
        bc = BoostedContent.new(@valid_attributes.merge(:title => 'sports', :description => 'speak'))
        bc.boosted_content_keywords.build(:value => 'dance')
        bc.save!
        BoostedContent.reindex
        Sunspot.commit
      end

      it "should find by title, description and keywords (ignoring stopwords), and highlight terms in the title and description" do
        title_search = BoostedContent.search_for('the sports', @affiliate)
        title_search.total.should == 1
        title_search.hits.first.highlight(:title).should_not be_nil
        description_search = BoostedContent.search_for('the speak', @affiliate)
        description_search.total.should == 1
        description_search.hits.first.highlight(:description).should_not be_nil
        BoostedContent.search_for('the dance', @affiliate).total.should == 1
      end
    end

    context "when the Boosted Content is in Spanish" do
      before do
        @spanish_affiliate = affiliates(:gobiernousa_affiliate)
        bc = BoostedContent.new(@valid_attributes.merge(:title => 'jugar Cambio de hora', :description => 'hablar Cambio de hora', :affiliate => @spanish_affiliate))
        bc.boosted_content_keywords.build(:value => 'caminar Cambio de hora')
        bc.save!
        BoostedContent.reindex
        Sunspot.commit
      end

      it "should find stemmed equivalents for the title, description and keywords (ignoring stopwords), and highlight terms in the title and description" do
        title_search = BoostedContent.search_for('jugando de hora', @spanish_affiliate)
        title_search.total.should == 1
        title_search.hits.first.highlight(:title_text).should_not be_nil
        description_search = BoostedContent.search_for('hablando de hora solamente', @spanish_affiliate)
        description_search.total.should == 1
        description_search.hits.first.highlight(:description_text).should_not be_nil
        BoostedContent.search_for('caminando de hora', @spanish_affiliate).total.should == 1
      end
    end

    context "when query contains special characters" do
      before do
        bc = BoostedContent.new(@valid_attributes.merge(:title => 'jugar', :description => 'hablar'))
        bc.boosted_content_keywords.build(:value => 'caminar')
        bc.save!
        BoostedContent.reindex
        Sunspot.commit
      end

      [ '"   ', '   "       ', '+++', '+-', '-+'].each do |query|
        specify { BoostedContent.search_for(query, @affiliate).should be_nil }
      end

      %w(+++jugar --hablar -+caminar).each do |query|
        specify { BoostedContent.search_for(query, @affiliate).total.should == 1 }
      end
    end

    context 'when query is for custom stemmed word' do
      before do
        BoostedContent.delete_all
        BoostedContent.create!(@valid_attributes.merge(title: 'APHIS Biotechnology', description: 'APHIS uses the term biotechnology to mean the use of recombinant DNA technology, or genetic engineering (GE) to modify living organisms. This is an organization.'))
        BoostedContent.reindex
        Sunspot.commit
      end

      %w(organic organics organically).each do |query|
        specify { BoostedContent.search_for(query, @affiliate).total.should be_zero }
      end

      %w(organizations organization organism organisms).each do |query|
        specify { BoostedContent.search_for(query, @affiliate).total.should == 1 }
      end
    end
  end

  describe "#display_status" do
    context "when status is set to active" do
      subject { BoostedContent.new(:status => 'active') }
      its(:display_status) { should == 'Active' }
    end

    context "when status is set to inactive" do
      subject { BoostedContent.new(:status => 'inactive') }
      its(:display_status) { should == 'Inactive' }
    end
  end
end
