class ChangeSummaryLengthInProjects < ActiveRecord::Migration
  def change
    change_column :projects, :summary, :string, limit: 300
  end
end
