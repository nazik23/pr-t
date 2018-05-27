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
