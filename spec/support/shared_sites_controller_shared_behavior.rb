# frozen_string_literal: true

shared_examples 'restricted to approved user' do |request_method, action, parameters = nil|
  context 'when user is not logged in' do
    it 'redirects to login page' do
      send request_method, action, params: parameters
      expect(response).to redirect_to(login_path)
    end
  end

  context 'when user is pending approval' do
    before { UserSession.create(users(:affiliate_manager_with_pending_approval_status)) }

    it 'redirects to affiliates page' do
      send request_method, action, params: parameters
      expect(response).to redirect_to(account_path)
    end
  end
end

shared_context 'approved user logged in' do
  let(:current_user) { users(:affiliate_manager) }

  before do
    UserSession.create current_user
    allow(User).to receive(:find_by_id).and_return(current_user)
  end
end

shared_context 'super admin logged in' do
  fixtures :users
  let(:current_user) { users(:affiliate_admin) }

  before do
    activate_authlogic
    UserSession.create current_user
    allow(User).to receive(:find_by_id).and_return(current_user)
  end
end

shared_context 'approved user logged in to a site' do
  let(:current_user) { users(:affiliate_manager) }
  let(:site) { affiliates(:basic_affiliate) }

  before do
    UserSession.create current_user
    allow(User).to receive(:find_by_id).and_return(current_user)
    allow(current_user).to receive_message_chain(:affiliates, :active, :find).and_return(site)
  end
end

shared_context 'super admin logged in to a site' do
  let(:current_user) { users(:affiliate_admin) }
  let!(:site) { affiliates(:basic_affiliate) }

  before do
    UserSession.create current_user
    allow(User).to receive(:find_by_id).and_return(current_user)
    allow(Affiliate).to receive(:find).with(site.id.to_s).and_return site
  end
end
