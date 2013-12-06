ThinkingSphinx::Index.define :project, :with => :real_time do
  indexes title
  indexes summary
  indexes location_name
  indexes category(:name), as: :category_name
  indexes rewards.description, as: :reward_description
  indexes story.description, as: :story_description
  indexes story.risks, as: :story_risks
  indexes story.why_we_need_help, as: :story_why_we_need_help
  indexes story.faq, as: :story_faq
  indexes story.about_the_team, as: :story_about_the_team
  indexes project_state

  has deadline, :type => :timestamp
  has published_at, :type => :timestamp
end
