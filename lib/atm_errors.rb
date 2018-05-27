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
