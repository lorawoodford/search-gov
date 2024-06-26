require 'spec_helper'

describe '/clicked' do
  let(:endpoint) { '/clicked' }
  let(:valid_params) do
    {
      url: 'https://example.gov',
      query: 'test_query',
      position: '1',
      affiliate: 'test_affiliate',
      vertical: 'test_vertical',
      module_code: 'BWEB'
    }
  end
  let(:click_model) { Click }
  let(:click_mock) { instance_double(click_model, log: nil) }

  include_context 'when the click request is browser-based'

  it_behaves_like 'a successful click request'

  context 'with authenticty token checking turned on' do
    before do
      ActionController::Base.allow_forgery_protection = true
    end

    it_behaves_like 'a successful click request'

    after do
      ActionController::Base.allow_forgery_protection = false
    end
  end

  context 'with invalid params' do
    let(:invalid_params) do
      {
        url: nil,
        query: nil,
        position: nil,
        affiliate: nil,
        vertical: nil,
        module_code: nil
      }
    end
    let(:expected_error_msg) do
      "[\"Module code can't be blank\",\"Position can't be blank\"," \
        "\"Query can't be blank\",\"Url can't be blank\"]"
    end

    it_behaves_like 'an unsuccessful click request'
  end

  it_behaves_like 'does not accept GET requests'
  it_behaves_like 'urls with invalid utf-8'
end
