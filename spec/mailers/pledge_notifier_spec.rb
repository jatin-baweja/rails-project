require "spec_helper"

describe PledgeNotifier do
  describe "inform_pledger" do
    let(:mail) { PledgeNotifier.inform_pledger }

    it "renders the headers" do
      mail.subject.should eq("Inform pledger")
      mail.to.should eq(["to@example.org"])
      mail.from.should eq(["from@example.com"])
    end

    it "renders the body" do
      mail.body.encoded.should match("Hi")
    end
  end

  describe "inform_project_owner" do
    let(:mail) { PledgeNotifier.inform_project_owner }

    it "renders the headers" do
      mail.subject.should eq("Inform project owner")
      mail.to.should eq(["to@example.org"])
      mail.from.should eq(["from@example.com"])
    end

    it "renders the body" do
      mail.body.encoded.should match("Hi")
    end
  end

  describe "charged" do
    let(:mail) { PledgeNotifier.charged }

    it "renders the headers" do
      mail.subject.should eq("Charged")
      mail.to.should eq(["to@example.org"])
      mail.from.should eq(["from@example.com"])
    end

    it "renders the body" do
      mail.body.encoded.should match("Hi")
    end
  end

end
