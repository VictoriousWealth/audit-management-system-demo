Rails.application.config.x.session_cookie_name = (Rails.env.production? ? '_audit_management_system_session' : "_audit_management_system_#{Rails.env}_session")

Rails.application.config.action_dispatch.cookies_same_site_protection =
  Rails.env.production? ? :none : :lax

Rails.application.config.session_store :active_record_store,
  key: Rails.application.config.x.session_cookie_name,
  secure: !Rails.env.development? && !Rails.env.test?,
  httponly: true
