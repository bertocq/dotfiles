require 'irb/completion'

IRB.conf[:SAVE_HISTORY] = 1000

# IRB Prompt inspired by @the-spectator
# https://dev.to/thespectator/making-your-rails-console-interesting-pdc
def app_prompt
  rails_klass = Rails.application.class

  app_name =
    if rails_klass.respond_to? :module_parent
      rails_klass.module_parent
    else
      rails_klass.parent
    end

  "#{app_name.name}".blue
end

# target log path for irb history
def log_path
  rails_root = Rails.root
  "#{rails_root}/log/.irb-history"
end

def env_prompt
  "#{Rails.env}".send(env_prompt)
end

def env_color
  case Rails.env
  when "development"
    :green
  when "production"
    :red
  else
    :yellow
  end
end

class String
  def colorize(color_code)
    "\e[#{color_code}m#{self}\e[0m"
  end

  def red
    colorize(31)
  end

  def green
    colorize(32)
  end

  def yellow
    colorize(33)
  end

  def blue
    colorize(36)
  end
end

def rails_prompt
  if defined?(Rails)
    IRB.conf[:HISTORY_FILE] = FileUtils.touch(log_path).join
    IRB.conf[:PROMPT] ||= {}
    "#{app_prompt}[#{env_prompt}]:%03n "
  end
end

IRB.conf[:PROMPT][:RAILS_EMOJI] = {
  :PROMPT_I => "#{rails_prompt}\u{1F479} > ", # default prompt
  :PROMPT_N => "#{rails_prompt}\u{1F914} > ", # unknown continuation
  :PROMPT_S => "#{rails_prompt}\u{1F60F} > ", # continuated string
  :PROMPT_C => "#{rails_prompt}\u{1F605} > ", # continuated statement
  :RETURN   => "  => %s\n",
  :AUTO_INDENT => true
}

IRB.conf[:PROMPT_MODE] = :RAILS_EMOJI
