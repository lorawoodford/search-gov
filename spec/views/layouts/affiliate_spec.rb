require "#{File.dirname(__FILE__)}/../../spec_helper"
describe "layouts/affiliate" do
  before do
    affiliate_template = stub('affiliate template', :stylesheet => 'default')
    affiliate = stub('affiliate', :header => 'header', :footer => 'footer', :is_sayt_enabled => false, :is_affiliate_suggestions_enabled => false, :affiliate_template => affiliate_template)
    assigns[:affiliate] = affiliate
  end
  context "when page is displayed" do
    it "should should show webtrends javascript" do
      render
      response.body.should have_tag("script[src=/javascripts/webtrends_affiliates.js][type=text/javascript]")
    end
  end
end