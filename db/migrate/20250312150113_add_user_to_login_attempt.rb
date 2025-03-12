class AddUserToLoginAttempt < ActiveRecord::Migration[7.0]
  def change
    add_reference :login_attempts, :user, null: false, foreign_key: true
  end
end
