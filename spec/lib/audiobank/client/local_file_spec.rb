require 'spec_helper'

describe Audiobank::Client::LocalFile do

  def local_file(filename)
    Audiobank::Client::LocalFile.new(filename)
  end

  describe "document_id" do

    it "should be the number which starts filename" do
      local_file("123-dummy.wav").document_id.should == 123
    end

    it "should be nil when filename doesn't start with a number" do
      local_file("dummy.wav").document_id.should be_nil
    end

  end

end
