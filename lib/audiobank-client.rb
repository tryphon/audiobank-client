require "audiobank/client/version"

require 'logger'
require 'json'

require "virtus"

require "null_logger"
require "active_support/core_ext/module/attribute_accessors"
require "active_support/core_ext/class/attribute_accessors"

require "active_support/core_ext/module/delegation"
require "active_support/json"
require "active_support/core_ext/object/to_json"

require 'net/ftp'

module Audiobank
  module Client

    @@logger = NullLogger.instance
    mattr_accessor :logger

  end
end


require "audiobank/document"
require "audiobank/documents"
require "audiobank/account"
