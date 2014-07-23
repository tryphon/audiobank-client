require 'tempfile'
require 'tmpdir'

module Audiobank::Client
  class LocalFile

    attr_reader :filename, :uploaded_file

    def initialize(filename)
      @filename = @uploaded_file = filename
    end

    def filename_without_extension
      @filename_without_extension ||= filename.gsub(/\.#{extension}$/, "")
    end

    def basename
      @basename ||= File.basename(filename)
    end

    def extension
      @extension ||= File.extname(filename)[1..-1]
    end

    def document_id
      if basename =~ /^([0-9]+)-/
        $1.to_i
      end
    end

    def file_uuid
      document_id or Digest::SHA256.hexdigest(filename)
    end

    def default_title
      File.basename(filename, File.extname(filename))
    end

    def flac_file
      # "#{filename_without_extension}.flac"
      # (@flac_tempfile ||= Tempfile.new(['audiobank', '.flac'])).path
      "/tmp/#{file_uuid}.flac"
    end

    def convert
      if extension == "wav"
        # unless FileUtils.uptodate? flac_file, filename
          Audiobank::Client.logger.info "Create flac version"
          system "flac -f -o #{flac_file} '#{filename}'" or raise "Can't convert file to wav"
        # end
        Audiobank::Client.logger.info "Use flac version"
        @uploaded_file = flac_file
      end
    end

    def import_options
      { :resume => true, :debug => true, :retries => 10, :progress => true }
    end

    def import(account)
      unless FileUtils.uptodate? uploaded_file, [report_file]
        Audiobank::Client.logger.info "File already imported"
        return
      end

      convert

      imported = false
      if document_id
        Audiobank::Client.logger.debug "Found document id : #{document_id}"
        document = account.document(document_id)
        if document
          imported = document.import uploaded_file, import_options
        else
          raise "Document #{document_id} not found"
        end
      else
        imported = account.documents.import uploaded_file, { :title => default_title }, import_options
      end

      if imported
        Audiobank::Client.logger.debug "Create report #{report_file}"
        system "touch '#{report_file}'"
        # FileUtils.touch report_file
      else
        Audiobank::Client.logger.info "Failed to import #{filename}"
      end
    end

    def report_file
      "#{filename}.audiobank"
    end

  end
end
