Sentry.init do |config|
  # Sentry is only enabled when the dsn is set.
  unless Rails.env.development? || Rails.env.test?
    config.dsn = 'https://0f65d610387ba6d764c09366ab42b8ed@sentry.shefcompsci.org.uk/24'
  end
  config.breadcrumbs_logger = [:active_support_logger, :http_logger]
  config.before_send = -> (event, hint) { ActiveSupport::ParameterFilter.new(Rails.application.config.filter_parameters).filter(event.to_hash) }
  config.excluded_exceptions += [
    'ActionController::BadRequest',
    'ActionController::UnknownFormat',
    'ActionController::UnknownHttpMethod',
    'ActionDispatch::Http::MimeNegotiation::InvalidType',
    'CanCan::AccessDenied',
    'Mime::Type::InvalidMimeType',
    'Rack::QueryParser::InvalidParameterError',
    'Rack::QueryParser::ParameterTypeError',
    'SystemExit',
    'URI::InvalidURIError',
  ]
end