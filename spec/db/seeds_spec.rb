require 'spec_helper'

describe 'db seeds' do
  before { allow(Rails.env).to receive(:development?).and_return(true) }

  context 'when I14y is not running' do
    it { expect { Rails.application.load_seed }.not_to raise_exception }

    it 'skips i14y seed data' do
      expect { Rails.application.load_seed }.
        to output(/Skipping i14yDrawer and SearchgovDomain seeds as there is no running I14y instance/).to_stdout
    end
  end

  context 'when I14y is running' do
    before do
      stub_request(:get, I14y.host).to_return(status: 200)
    end

    it { expect { Rails.application.load_seed }.not_to raise_exception }

    it 'creates i14y seed data' do
      expect { Rails.application.load_seed }.
        to output(/Creating I14y Drawer/).to_stdout
    end
  end
end
