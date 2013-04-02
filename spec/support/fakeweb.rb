require 'fakeweb'

class Audiobank::Account

  def register_uri(method, url, options = {})
    complete_url = "#{self.class.base_uri}/documents.json?auth_token=#{token}"
    FakeWeb.register_uri method, complete_url, options
  end

end
