class Audiobank::Documents

  attr_accessor :account

  def initialize(account)
    @account = account
  end

  delegate :post, :to => :account

  def create(attributes)
    Audiobank::Client.logger.debug "Create AudioBank document : #{attributes.inspect}"
    post "/documents.json", :document => attributes do |response|
      Audiobank::Document.new(response).tap do |document|
        document.account = account
        Audiobank::Client.logger.debug "Created document has id #{document.id}"
      end
    end
  end

  def import(file, attributes = {}, options = {})
    attributes = {
      :title => File.basename(file, File.extname(file)),
      :description => "Uploaded at #{Time.now}"
    }.merge(attributes)

    create(attributes).import(file, options)
  end

end
