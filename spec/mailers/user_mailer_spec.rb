require "rails_helper"

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
      expect(mail.from).to eq(["GTIMC@mailer.com"])
    end

    it "has the recipient's email in the body" do
      expect(mail.body.encoded).to include("test@example.com")
    end
  end
end
