## Application deployment configuration
set :server,      'PRODUCTION_SERVER'
set :user,        'PRODUCTION_USER'
set :deploy_to,   -> { "/srv/services/#{fetch(:user)}" }
set :branch,      'production'
set :application, fetch(:user)

## Server configuration
server fetch(:server), user: fetch(:user), roles: %w{web app db}, ssh_options: { forward_agent: true }

## Additional tasks
namespace :deploy do
  task :seed do
    on primary :db do within current_path do with rails_env: fetch(:stage) do
      execute :rake, 'db:seed'
    end end end
  end
end

# This bit if for the email configuration
# This is the production environment configuration for Action Mailer
# It sets up the SMTP settings for sending emails in production
# Make sure to replace the SMTP settings with your actual email service provider's settings

Rails.application.configure do
  # Other configurations for production

  # Configure action mailer to send real emails
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.default_url_options = { host: 'team17.demo3.hut.shefcompsci.org.uk' }  # Replace with your production domain

  # SMTP settings for Gmail (example)
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    address: 'smtp.gmail.com',
    port: 587,
    domain: 'gmail.com',
    user_name: ENV['GMAIL_USERNAME'],  # Set your Gmail username in the environment variables
    password: ENV['GMAIL_PASSWORD'],   # Set your Gmail password in the environment variables
    authentication: 'plain',
    enable_starttls_auto: true
  }

  # Ensure emails are delivered in production
  config.action_mailer.perform_deliveries = true
end
