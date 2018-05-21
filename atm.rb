require 'yaml'
require 'forwardable'

config = YAML.load_file(ARGV.first || '/home/nazik23/work/pivorak-test/config.yml')

class Atm
  attr_reader :banknotes
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
	attr_reader :client

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

class Account

  def initialize(name, password, balance)
	  @name = name
		@password = password
		@balance = balance
	end

	def withdraw(amount)
	  self.balance -= amount
	end

	def correct_password? (received_password)
	  password == received_password
	end

	def check_possibility_to_withdraw(amount)
		raise InsufficientFundsOnAccountError if amount > balance
	end

  attr_reader :name, :balance

	private 
	  attr_writer :balance
		attr_reader :password
end

class Accounts
	@all = []

	class << self

		def set_accounts(registered_accounts)
	    @all = registered_accounts
	  end

		def has_account_with(account_number:, password:)
			return false unless all.include? account_number
			get_account(account_number).correct_password? password
		end

		def get_account(account_number)
			all[account_number]
		end

		private
	  attr_reader :all
	end
end

class AtmInterface
  attr_reader :atm

	ATM_MENU = [
		"\nPlease Choose From the Following Options:",
		"  1. Display Balance",
		"  2. Withdraw",
		"  3. Log Out"
	]

  def initialize(atm)
	  @atm = atm
	end

	def start_atm
	  loop{
			begin
	  		client_info = get_client_info
				raise AccountNumberAndPasswordError unless Accounts.has_account_with account_number: client_info[:account_number], password:  client_info[:password]

				set_user(client_info[:account_number])
	  		
	  		loop{
	  			puts ATM_MENU
					puts "\n"

					menu_item = get_user_input type: Integer
	  			
	  			break if (proceed_user_choise(menu_item) == 'logout')
				}
			rescue AccountNumberAndPasswordError => e
				puts e.message 
 			 	puts "\n"
				retry
			end
		}
	end

	private

	def get_client_info
	  puts 'Please Enter Your Account Number:'
		account_number = get_user_input type: Integer
		puts 'Enter Your Password:'
		account_password = get_user_input
		{account_number: account_number, password: account_password}
	end

	def set_user(number)
	  atm.current_client Accounts.get_account number
		puts "\nHello, #{atm.client_name}!"
	end

	def get_user_input(type: nil)
	  if type == Integer
			gets.chomp.to_i
		else
			gets.chomp
		end
	end

	def proceed_user_choise(received_number)
	  case received_number
		when 1
		  show_client_balance
		when 2
			withdraw
		when 3
      log_out_client	  
			'logout'
		end
	end

	def show_client_balance(after_withdraw: false)
		puts "\n"
		puts "Your #{after_withdraw ? "New": "Current"} Balance is ₴#{atm.client_balance}"
	end

	def withdraw
	  puts "\nEnter Amount You Wish to Withdraw:"
		begin
			amount = get_user_input type: Integer
			atm.withdraw(amount)
		rescue WithdrawError => e
			puts e.message
			retry
		end
		show_client_balance after_withdraw: true
	end

	def log_out_client
	  puts "\n#{atm.client_name}, Thank You For Using Our ATM. Good-Bye!"
		puts "\n"
		atm.current_client nil
	end
end

class AccountNumberAndPasswordError < StandardError
	def initialize
		super "\nERROR: ACCOUNT NUMBER AND PASSWORD DON'T MATCH"
	end
end

class WithdrawError < StandardError; end

class InsufficientFundsOnAccountError < WithdrawError
	def initialize
		super "\nERROR: INSUFFICIENT FUNDS!! PLEASE ENTER A DIFFERENT AMOUNT:"
	end
end

class InsufficientFundsInAtmError < WithdrawError
	def initialize(balance: 0)
		super "\nERROR: THE MAXIMUM AMOUNT AVAILABLE IN THIS ATM IS ₴#{balance}. PLEASE ENTER A DIFFERENT AMOUNT:"
	end
end

class AmountComposeError < WithdrawError
	def initialize
		super "\nERROR: THE AMOUNT YOU REQUESTED CANNOT BE COMPOSED FROM BILLS AVAILABLE IN THIS ATM. PLEASE ENTER A DIFFERENT AMOUNT:"
	end
end

accounts = {}
config['accounts'].each do |number, configurations|
  accounts[number] = Account.new(configurations['name'], configurations['password'], configurations['balance'])
end
Accounts.set_accounts accounts

AtmInterface.new(Atm.new(config['banknotes'])).start_atm
