class DeleteUnnecesseryFieldsFromUser < ActiveRecord::Migration[5.0]
  def change
    change_table(:users) do |t|
      ## Recoverable
      t.remove :reset_password_token
      t.remove :reset_password_sent_at

      ## Rememberable
      t.remove :remember_created_at

      ## Confirmable
      t.remove :confirmation_token
      t.remove :confirmed_at
      t.remove :confirmation_sent_at
      t.remove :unconfirmed_email # Only if using reconfirmable
    end
  end
end
