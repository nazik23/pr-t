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
