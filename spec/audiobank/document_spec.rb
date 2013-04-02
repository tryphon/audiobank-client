require 'spec_helper'

describe Audiobank::Document do

  subject { Audiobank::Document.new :id => 1, :account => account }

  let(:account) { Audiobank::Account.new("secret") }

  describe "#errors=" do

    let(:errors) { %w{first second} }
    
    it "should parse JSON array" do
      subject.errors = errors.to_json
      subject.errors.should == errors
    end

    it "should accept errors array" do
      subject.errors = errors
      subject.errors.should == errors
    end

  end

  it "should be valid when errors is blank" do
    subject.errors = []
    subject.should be_valid
  end

  describe "#upload_uri" do
    
    it "should parse upload url" do
      subject.upload = "ftp://audiobank.tryphon.eu/directory"
      subject.upload_uri.host.should == "audiobank.tryphon.eu"
      subject.upload_uri.path.should == "directory"
    end

  end

  describe "confirm" do
    
    it "should post to /documents/:id/upload/confirm.json" do
      account.should_receive(:post).with "/documents/#{subject.id}/upload/confirm.json"
      subject.confirm
    end

  end

  describe "upload!" do
    
    it "should upload file in ftp" do
      pending "Use fake_ftp"
    end

    it "should return the document" do
      pending
    end

  end

end
