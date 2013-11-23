require 'spec_helper'

describe Story do

  before(:each) do
    @project = Project.new
    @story = @project.build_story(:description => 'Short Description', :why_we_need_help => 'Why we need help', :risks => 'Risks involved', :faq => 'FAQs', :about_the_team => 'About The Team')
  end

  it "is valid with valid attributes" do
    @story.should be_valid
  end

  it "is invalid without description" do
    @story.description = nil
    @story.should_not be_valid
  end

  it "is invalid without why_we_need_help" do
    @story.why_we_need_help = nil
    @story.should_not be_valid
  end

  it "is invalid without faq" do
    @story.faq = nil
    @story.should_not be_valid
  end

  it "is invalid without about_the_team" do
    @story.about_the_team = nil
    @story.should_not be_valid
  end

  it "is invalid without risks" do
    @story.risks = nil
    @story.should_not be_valid
  end

end
