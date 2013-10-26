class CreateBackersJoinTable < ActiveRecord::Migration
  def change
    create_join_table :projects, :users do |t|
      # t.index [:project_id, :user_id]
      t.index [:user_id, :project_id], unique: true
    end
  end
end
