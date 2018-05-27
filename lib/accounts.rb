class Accounts
	@all = {}

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
