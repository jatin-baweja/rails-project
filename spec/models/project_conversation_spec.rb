require 'spec_helper'

describe ProjectConversation do

  before(:each) do
    @project = Project.new
    @project_conversation = @project.project_conversations.build
    @project_conversation.converser_id = 2;
    @project_conversation.project_id = 3;
  end

  it "is valid with valid attributes" do
    @project_conversation.should be_valid
  end

  it "is invalid without converser" do
    @project_conversation.converser_id = nil
    @project_conversation.should_not be_valid
  end

  it "is invalid without project" do
    @project_conversation.project_id = nil
    @project_conversation.should_not be_valid
  end

end
