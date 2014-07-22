require 'spec_helper'

describe Audiobank::Documents do

  let(:account) { Audiobank::Account.new "secret" }

  subject { Audiobank::Documents.new account }

  before(:each) do
    FakeWeb.allow_net_connect = false
  end

  describe "#create" do

    it "should post to /documents.json the document attributes" do
      account.should_receive(:post).with("/documents.json", :document => { :title => "dummy" })
      subject.create :title => "dummy"
    end

    it "should return a Document with received attributes" do
      account.register_uri :post, "/documents.json", :body => {"title" => "dummy"}.to_json
      subject.create({}).title.should == "dummy"
    end

    it "should return a Document associated to the account" do
      account.register_uri :post, "/documents.json"
      subject.create({}).account.should == account
    end

  end

  describe "#import" do

    let(:document) { mock }
    let(:file) { "/path/to/file" }

    before do
      subject.stub :create => document
      document.stub :import => true
    end

    it "should create a Document with specified attributes" do
      subject.should_receive(:create).with(hash_including(:title => "dummy")).and_return(document)
      subject.import file, :title => "dummy"
    end

    it "should import the document" do
      document.should_receive(:import)
      subject.import file
    end

    it "should use the filename (without extension) as default title" do
      subject.should_receive(:create).with(hash_including(:title => "filename")).and_return(document)
      subject.import "/path/to/filename.flac"
    end

    it "should use a default description" do
      subject.should_receive(:create).with(hash_including(:description)).and_return(document)
      subject.import file
    end

  end

end
