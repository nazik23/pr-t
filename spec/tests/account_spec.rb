require 'account'
require 'atm_errors'

RSpec.describe Account do
	let(:account_attr){attributes_for(:account)}
	let(:account) { Account.new(*account_attr.map{|_, v| v})}
	
	it 'initialize with name, password and balance' do
		expect(account).to be_an_instance_of Account
	end

	context 'after initialize' do
		it 'can return name' do
			expect(account.name).to equal  account_attr[:name]
		end

		it 'can return balance' do
			expect(account.balance).to equal account_attr[:balance]
		end

		it "can't show a password" do
			expect{account.password}.to raise_error NoMethodError
		end

		context 'respond to correct_password? to compare with inputed password' do
			it 'if password correct return true' do
				expect(account.correct_password? account_attr[:password]).to be_truthy
			end

			it 'if password mismatch return false' do
				expect(account.correct_password? 'some password').to be_falsy
			end
		end

		context "can check account's possibility to withdraw inputed amount" do
			it "raises InsufficientFundsOnAccountError if requested amount is greater than account's balance" do
				expect{account.check_possibility_to_withdraw (account_attr[:balance] + 100)}.to raise_error InsufficientFundsOnAccountError
			end
		end

		it 'can withdraw amount' do
			expect{account.withdraw 100}.to change{account.balance}.from(account_attr[:balance]).to(account_attr[:balance] - 100)
		end
	end
end
