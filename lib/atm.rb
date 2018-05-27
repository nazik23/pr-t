require 'forwardable'

class Atm
	extend Forwardable
							 
	[:name, :balance].each do |meth| 
		def_delegator :@client, meth, "client_#{meth}".to_sym
	end

  def initialize(banknotes)
	  @banknotes = banknotes 
	end

	def current_client(client)
	  @client = client
	end

	def withdraw(amount)
		client.check_possibility_to_withdraw amount

		atm_balance = count_balance
		raise InsufficientFundsInAtmError.new(balance: atm_balance) if amount > atm_balance

	  amount_in_banknotes = fetch(amount)
		raise AmountComposeError if amount_in_banknotes.empty?

		client.withdraw(amount)
		banknotes.merge!(amount_in_banknotes) do |banknote_value, actual_quantity, withdrawal_quantity|
			actual_quantity - withdrawal_quantity
		end
	end

	private
	attr_reader :client, :banknotes

	def count_balance
	  banknotes.map{|nominal, quantity| nominal * quantity}.inject(:+)
	end

	def fetch(amount)
	  banknotes_values = banknotes.keys
		amount_in_banknotes = {}

		banknotes_values.each do |banknote_value|
		  max_banknotes_need = amount / banknote_value

			current_banknotes = [max_banknotes_need, banknotes[banknote_value]].min

			next if current_banknotes.zero?

			amount_in_banknotes[banknote_value] = current_banknotes

			amount -= banknote_value * current_banknotes
		end

		amount.zero? ? amount_in_banknotes : {}
	end
end
