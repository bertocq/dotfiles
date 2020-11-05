if defined?(PryByebug)
  Pry.commands.alias_command 'cc', 'continue'
  Pry.commands.alias_command 'ss', 'step'
  Pry.commands.alias_command 'nn', 'next'
  Pry.commands.alias_command 'ff', 'finish'
end

Pry.commands.alias_command 'ee', 'exit'
Pry.commands.alias_command 'sh', 'show-source'
Pry.commands.alias_command 'dd', 'disable-pry'

begin
  require 'awesome_print'
  AwesomePrint.pry!
rescue LoadError
  warn "awesome_print not installed"
end

Pry::Commands.command "sql", "Send sql over AR." do |query|
  if ENV['RAILS_ENV'] || defined?(Rails)
    ap ActiveRecord::Base.connection.select_all(query).to_a
  else
    ap "No rails env defined"
  end
end
