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
#  video            :string(255)
#  why_we_need_help :text
#  faq              :text
#  about_the_team   :text
#

class Story < ActiveRecord::Base
  belongs_to :project

  validates :description, :risks, :why_we_need_help, :faq, :about_the_team, presence: true
end
