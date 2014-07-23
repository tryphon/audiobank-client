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

  class NullProgressBar

    def inc(size); end
    def set(size); end
    def finish; end

  end

  def upload!(file, options = {})
    Audiobank::Client.logger.debug "Upload #{file} in document #{id} (#{upload_uri})"

    retry_count = (options[:retries] or 0)

    progress_bar = (options[:progress] ? ProgressBar.new("Document #{id}", File.size(file)) : NullProgressBar.new)

    begin
      Net::FTP.open(upload_uri.host) do |ftp|
        ftp.debug_mode = options[:debug]
        ftp.login
        ftp.chdir upload_uri.path
        ftp.resume = options[:resume]
        ftp.passive = true
        ftp.putbinaryfile file, id.to_s do |buf|
          progress_bar.inc buf.size
        end
      end

      progress_bar.finish
    rescue => e
      Audiobank::Client.logger.debug "Upload #{file} failed #{e}"
      if retry_count > 0
        retry_count -= 1
        progress_bar.set 0
        Audiobank::Client.logger.debug "Retry in 30 seconds"
        sleep 30
        retry
      else
        return nil
      end
    end

    self
  end

  def confirm
    Audiobank::Client.logger.debug "Confirm upload of document #{id}"
    account.post "/documents/#{id}/upload/confirm.json"
  end

  def import(file, options = {})
    upload!(file, options).try(:confirm)
  end

end
