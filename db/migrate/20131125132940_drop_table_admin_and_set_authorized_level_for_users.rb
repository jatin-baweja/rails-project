class DropTableAdminAndSetAuthorizedLevelForUsers < ActiveRecord::Migration

  def up
    users = User.all
    users.each do |user|
      user.authorized_level = 'regular'
      user.save!
    end
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
