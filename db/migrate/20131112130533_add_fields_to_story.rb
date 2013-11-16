class AddFieldsToStory < ActiveRecord::Migration
  def change
    add_column :stories, :why_we_need_help, :text
    add_column :stories, :faq, :text
    add_column :stories, :about_the_team, :text
  end
end
