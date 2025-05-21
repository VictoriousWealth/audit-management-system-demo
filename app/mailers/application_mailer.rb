class ApplicationMailer < ActionMailer::Base
  default from: "mailhost.shef.ac.uk"
  layout "mailer"
end
