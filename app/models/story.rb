# == Schema Information
#
# Table name: stories
#
#  id               :integer          not null, primary key
#  description      :text
#  risks            :text
#  created_at       :datetime
#  updated_at       :datetime
#  project_id       :integer
#  why_we_need_help :text
#  faq              :text
#  about_the_team   :text
#

class Story < ActiveRecord::Base
  after_save :set_project_delta_flag
  after_destroy :set_project_delta_flag

  belongs_to :project

  validates :description, :risks, :why_we_need_help, :faq, :about_the_team, presence: true

  def set_project_delta_flag
    project.delta = true
    project.save
  end

end
