class RemoveImageFieldFromProject < ActiveRecord::Migration
  def change
    remove_attachment :projects, :image
  end
end
