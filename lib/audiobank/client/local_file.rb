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

    def convert
      if extension == "wav"
        flac_file = "#{filename_without_extension}.flac"
        unless FileUtils.uptodate? flac_file, filename
          Audiobank::Client.logger.info "Create flac version"
          system "flac -s -f -o #{flac_file} #{filename}" or raise "Can't convert file to wav"
        end
        Audiobank::Client.logger.info "Use flac version"
        @uploaded_file = flac_file
      end
    end

    def import(account)
      convert

      unless FileUtils.uptodate? uploaded_file, report_file
        Audiobank::Client.logger.info "File already imported"
        return
      end

      if document_id
        Audiobank::Client.logger.debug "Found document id : #{document_id}"
        document = account.document(document_id)
        if document
          document.import uploaded_file
        else
          raise "Document #{document_id} not found"
        end
      else
        account.documents.import uploaded_file
      end

      Audiobank::Client.logger.debug "Create report #{report_file}"
      FileUtils.touch report_file
    end

    def report_file
      "#{filename}.audiobank"
    end

  end
end
