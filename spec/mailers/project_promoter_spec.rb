require "spec_helper"

describe ProjectPromoter do
  describe "promote" do
    let(:mail) { ProjectPromoter.promote }

    it "renders the headers" do
      mail.subject.should eq("Promote")
      mail.to.should eq(["to@example.org"])
      mail.from.should eq(["from@example.com"])
    end

    it "renders the body" do
      mail.body.encoded.should match("Hi")
    end
  end

end
