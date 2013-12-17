class DropTableAdminAndSetAuthorizedLevelForUsers < ActiveRecord::Migration

  def up
    drop_table :admins
  end

  def down
    create_table :admins do |t|
      t.string :email
      t.string :password_digest

      t.timestamps
    end
  end

end
