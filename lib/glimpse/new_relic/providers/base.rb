module Glimpse
  module NewRelic
    module Providers
      class Base
        def self.inherited(subclass)
          @subclasses ||= []
          @subclasses << (subclass)
        end

        def self.subclasses
          @subclasses
        end

        def self.autoload_providers
          self_path = File.expand_path(__FILE__)
          providers_path = File.dirname(self_path)
          providers = Dir[File.join(providers_path, '*.rb')]
          (providers - [self_path]).each do |provider_path|
            require provider_path
          end
        end

        def self.valid?
          true
        end

        def self.has_rails?
          defined?(::Rails)
        end

        def initialize
        end

        def name
          self.class.name.split("::").last
        end

        def begin_request(env, request_uuid)
        end

        def end_request(env, request_uuid, status, headers, response, duration)
        end

        def data_for_request(*args)
        end
      end
    end
  end
end
