# config/initializers/require_logger.rb
require "logger"

# Workaround for ActiveSupport::LoggerThreadSafeLevel
module ActiveSupport
  module LoggerThreadSafeLevel
    # Reopen the module to ensure Logger is defined
    Logger = ::Logger
  end
end
