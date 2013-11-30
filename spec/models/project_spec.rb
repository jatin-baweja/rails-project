require 'spec_helper'

describe Project do

  context "after step 1" do

    before(:each) do
      @project = Project.new(:title => 'New Project', :summary => 'Just a short summary', :location_name => 'New Delhi')
      @project.step = 1
    end

    it "is valid with valid attributes" do
      @project.should be_valid
    end

    it "is invalid without title" do
      @project.title = nil
      @project.should_not be_valid
    end

    it "is invalid without summary" do
      @project.summary = nil
      @project.should_not be_valid
    end

    it "is invalid without location" do
      @project.location_name = nil
      @project.should_not be_valid
    end

    it "is invalid with title length greater than 60" do
      @project.title = 'This is such a long title that it must fail the length validation'
      @project.should_not be_valid
    end

    it "is invalid with summary length greater than 300" do
      @project.summary = 'Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla'
      @project.should_not be_valid
    end

  end

  context "after step 3" do

    before(:each) do
      @project = Project.new(:title => 'New Project', :summary => 'Just a short summary', :location_name => 'New Delhi', :goal => 20000, :duration => 25, :published_at => Time.now + 5.days)
      @project.step = 3
    end

    it "is valid with valid attributes" do
      @project.should be_valid
    end

    it "is invalid without funding amount" do
      @project.goal = nil
      @project.should_not be_valid
    end

    it "is invalid without duration" do
      @project.duration = nil
      @project.should_not be_valid
    end

    it "is invalid without publish_on" do
      @project.published_at = nil
      @project.should_not be_valid
    end

    it "is invalid if funding amount is negative" do
      @project.goal = -2
      @project.should_not be_valid
    end

    it "is invalid if funding amount is not an integer" do
      @project.goal = 23.34
      @project.should_not be_valid
    end

    it "is invalid if duration is negative" do
      @project.duration = -2
      @project.should_not be_valid
    end

    it "is invalid if duration is not an integer" do
      @project.duration = 23.34
      @project.should_not be_valid
    end

    it "is invalid if duration is greater than 29" do
      @project.duration = 30
      @project.should_not be_valid
    end

  end

end
