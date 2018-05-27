require 'atm'
require 'account'
require 'atm_errors'

RSpec.describe Atm do
	let(:client){Account.new(*attributes_for(:account).map{|_, v| v})}
	let(:atm) { Atm.new(attributes_for(:atm)[:banknotes])}

	it 'inititalize with banknotes' do 
		expect(atm).to be_an_instance_of Atm
	end

	it 'should set a current client' do
		expect(atm.current_client client).to be_truthy
	end

	context 'after set a client' do
		before(:each) { atm.current_client client}

		it 'can show client balance' do
			expect(atm.client_balance).to eq(client.balance)
		end

		it 'can show client name' do
			expect(atm.client_name).to eq client.name
		end

		context 'withdraw amount' do
			it "raise InsufficientFundsOnAccountError if requested amount is greater than client's balance" do
				expect{atm.withdraw client.balance + 100}.to raise_error InsufficientFundsOnAccountError
			end

			it "raise InsufficientFundsInAtmError if requested amount is greater than atm's balance" do
				expect{atm.withdraw client.balance - 1}.to raise_error InsufficientFundsInAtmError
			end

			it "raise AmountComposeError if amount can't be composed from atm's bills" do
				expect{atm.withdraw 13}.to raise_error AmountComposeError
			end

			it "if all conditions are satisfied withdraw amount from client's balance" do
				expect{atm.withdraw 200}.to change{client.balance}.by(-200)
			end
		end
	end
end
