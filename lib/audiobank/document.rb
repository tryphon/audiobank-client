class Audiobank::Document
  include Virtus

  attribute :id, Integer
  attribute :download_count, Integer
  attribute :description, String
  attribute :length, Integer
  attribute :title, String
  attribute :cast, String
  attribute :upload, String

  attr_accessor :account
  attr_accessor :errors

  def errors=(errors)
    @errors = (String === errors ? JSON.parse(errors) : errors)
  end

  def valid?
    errors.blank?
  end

  def upload_uri
    @upload_uri ||= URI.parse(upload)
  end

  def upload!(file)
    Net::FTP.open(upload_uri.host) do |ftp|
      ftp.login
      ftp.chdir upload_uri.path
      ftp.putbinaryfile file 
    end

    self
  end

  def confirm
    account.post "/documents/#{id}/upload/confirm.json"
  end

end
