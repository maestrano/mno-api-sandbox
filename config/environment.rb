# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
MnoApiSandbox::Application.initialize!

class Logger
  def format_message(level, time, progname, msg)
    if level =~ /error/i
      "#{level}: #{msg}\n"
    else
      "#{msg}\n"
    end
  end
end
