if defined?(PryByebug)
  Pry.commands.alias_command 'c', 'continue'
  Pry.commands.alias_command 'w', 'whereami'
  Pry.commands.alias_command 'n', 'next'
  Pry.commands.alias_command 's', 'step'
  Pry.commands.alias_command 'f', 'finish'
end

Pry.commands.alias_command 'e', 'exit'
Pry.commands.alias_command 's', 'show-source'
Pry.commands.alias_command 'd', 'disable-pry'

# begin
#   require 'awesome_print'
#   AwesomePrint.pry!
# rescue LoadError
#   warn "awesome_print not installed"
# end

Pry::Commands.command "sql", "Send sql over AR." do |query|
  if ENV['RAILS_ENV'] || defined?(Rails)
    ap ActiveRecord::Base.connection.select_all(query).to_a
  else
    ap "No rails env defined"
  end
end
