require 'spec_helper'

describe HeaderAndFooterLinksUpdater do
  let(:header_and_footer_links_updater) { instance_double(described_class) }
  let(:run_task) do
    Rake.application.invoke_task "searchgov:header_and_footer_links_updater[#{ids}]"
  end
  let(:first_affiliate_id) { affiliates(:basic_affiliate).id }
  let(:second_affiliate_id) { affiliates(:usagov_affiliate).id }
  let(:third_affiliate_id) { affiliates(:searchgov_affiliate).id }
  let(:ids) { "#{first_affiliate_id} #{second_affiliate_id} #{third_affiliate_id}" }

  before do
    Rake.application.rake_require('tasks/header_and_footer_links_updater')
    Rake::Task.define_task(:environment)
    allow(described_class).to receive(:new).and_return(header_and_footer_links_updater)
    allow(header_and_footer_links_updater).to receive(:update)
  end

  context 'when all ids are passed as an argument' do
    before do
      Rake::Task['searchgov:header_and_footer_links_updater'].reenable
    end

    let(:ids) { 'all' }

    it 'calls the updater on those ids' do
      run_task

      expect(described_class).to have_received(:new)
      expect(header_and_footer_links_updater).to have_received(:update).with('all')
    end
  end

  context 'when select ids are passed as an argument' do
    before do
      Rake::Task['searchgov:header_and_footer_links_updater'].reenable
    end

    let(:ids) { "#{first_affiliate_id} #{second_affiliate_id}" }

    it 'calls the updater on those ids' do
      run_task

      expect(described_class).to have_received(:new)
      expect(header_and_footer_links_updater).to have_received(:update).with(ids)
    end
  end

  context 'when id argument is absent' do
    before do
      Rake::Task['searchgov:header_and_footer_links_updater'].reenable
    end

    let(:run_task) { Rake.application.invoke_task 'searchgov:header_and_footer_links_updater' }
    let(:warn_text) { "Please provide a space-separated list of affiliate ids or 'all' as a task argument. No affiliates updated.\n" }

    it 'raises a warning and exits' do
      expect { run_task }.to output(warn_text).to_stdout
    end
  end
end
