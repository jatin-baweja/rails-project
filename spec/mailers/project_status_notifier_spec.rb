require "spec_helper"

describe ProjectStatusNotifier do
  describe "published" do
    let(:mail) { ProjectStatusNotifier.published }

    it "renders the headers" do
      mail.subject.should eq("Published")
      mail.to.should eq(["to@example.org"])
      mail.from.should eq(["from@example.com"])
    end

    it "renders the body" do
      mail.body.encoded.should match("Hi")
    end
  end

  describe "failed" do
    let(:mail) { ProjectStatusNotifier.failed }

    it "renders the headers" do
      mail.subject.should eq("Failed")
      mail.to.should eq(["to@example.org"])
      mail.from.should eq(["from@example.com"])
    end

    it "renders the body" do
      mail.body.encoded.should match("Hi")
    end
  end

  describe "funded" do
    let(:mail) { ProjectStatusNotifier.funded }

    it "renders the headers" do
      mail.subject.should eq("Funded")
      mail.to.should eq(["to@example.org"])
      mail.from.should eq(["from@example.com"])
    end

    it "renders the body" do
      mail.body.encoded.should match("Hi")
    end
  end

end
