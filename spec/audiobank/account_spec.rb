require 'spec_helper'

describe Audiobank::Account do

  subject { Audiobank::Account.new("secret") }

  before(:each) do
    FakeWeb.allow_net_connect = false    
  end

  describe "#get" do
    
    it "should send get request to the specified url with auth_token" do
      FakeWeb.register_uri :get, "http://audiobank.tryphon.eu/dummy?auth_token=secret", :body => 'dummy'
      subject.get("/dummy").body.should == 'dummy'
    end

  end

  describe "#post" do
    
    it "should send post request to the specified url with auth_token" do
      FakeWeb.register_uri :post, "http://audiobank.tryphon.eu/dummy?auth_token=secret", :body => 'dummy'
      subject.post("/dummy", :key => "value")
      FakeWeb.last_request.body.should == '{"key":"value"}'
    end

  end
  
  describe "#document" do

    let(:json_response) {
      '{"download_count":5,"description":"Dummy","length":1744,"cast":"8a9cygzn","id":721,"upload":"ftp://audiobank.tryphon.eu/pqxijmcetmodn25s/","title":"Test"}'
    }

    it "should retrieve invoke http://audiobank.tryphon.eu/documents/<id>.json" do
      FakeWeb.register_uri :get, "http://audiobank.tryphon.eu/documents/1.json?auth_token=secret", :body => json_response
      subject.document(1).title.should == "Test"
    end

    it "should return nil if documet is not found" do
      FakeWeb.register_uri :get, "http://audiobank.tryphon.eu/documents/1.json?auth_token=secret", :status => ["404", "Not Found"]
      subject.document(1).should be_nil
    end

  end

  describe "#documents" do
    
    it "should be associated to this account" do
      subject.documents.account.should == subject
    end

  end

end
