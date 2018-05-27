require 'accounts'
require 'account'

RSpec.describe Accounts do
	context 'after sets accounts' do
		let(:account_attr){attributes_for(:account)}
		let(:acc_number){attributes_for(:accounts)[:account_number]}
		let(:acc){Account.new(*account_attr.map{|_, v| v})}
		before(:each){ Accounts.set_accounts({acc_number => acc})}

		it "can get account by account number" do
			expect(Accounts.get_account(acc_number)).to be acc
		end

		it "can check account presence with account number and password" do
			acc_password = account_attr[:password]
			[acc_password, 'another password'].each do |pass|
				response = Accounts.has_account_with(account_number: acc_number, password: pass)
				if pass == acc_password
					expect(response).to be true
				else
					expect(response).to be false
				end
			end
		end
	end
end
