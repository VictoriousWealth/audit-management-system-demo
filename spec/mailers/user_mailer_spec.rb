require "rails_helper"

# This spec tests the functionality of the UserMailer class
# - welcome_email: Notifies a new user about their account creation
#
# The tests verify that the email has the right content
#
RSpec.describe UserMailer, type: :mailer do
  describe "welcome_email" do
    let(:user) { create(:user, email: "test@example.com") }
    let(:mail) { UserMailer.welcome_email(user) }

    it "has the correct subject" do
      expect(mail.subject).to eq("GTIMC Account Creation")
    end

    it "sends the email to the correct address" do
      expect(mail.to).to eq([user.email])
    end

    it "has the correct sender email" do
      expect(mail.from).to eq(["mailhost.shef.ac.uk"])
    end

    it "has the recipient's email in the body" do
      expect(mail.body.encoded).to include("test@example.com")
    end
  end
end
