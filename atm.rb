require 'yaml'

Dir[Dir.pwd + "/lib/*.rb"].each do |file|
	require file
end

config = YAML.load_file(ARGV.first || 'config.yml')

accounts = {}
config['accounts'].each do |number, configurations|
  accounts[number] = Account.new(configurations['name'], configurations['password'], configurations['balance'])
end
Accounts.set_accounts accounts

AtmInterface.new(Atm.new(config['banknotes'])).start_atm
