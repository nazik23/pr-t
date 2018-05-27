FactoryBot.define do
	factory :atm do
		banknotes Hash[100, 2, 50, 1, 20, 2, 10, 4, 5, 1, 1, 2]
	end	
end
