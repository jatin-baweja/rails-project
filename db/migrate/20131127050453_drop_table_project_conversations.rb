class DropTableProjectConversations < ActiveRecord::Migration
  def up
    drop_table :project_conversations
  end

  def down
    create_table :project_conversations do |t|
      t.references :converser, polymorphic: true, index: true
      t.references :project, index: true

      t.timestamps
    end
  end
end
