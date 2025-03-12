class CreateLoginAttempts < ActiveRecord::Migration[7.0]
  def change
    create_table :login_attempts do |t|
      t.datetime :attempt_time
      t.boolean :success
      t.string :ip_address

      t.timestamps
    end
  end
end
