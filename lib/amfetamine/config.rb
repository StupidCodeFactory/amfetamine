module Amfetamine
  class Config
    class << self

      attr_reader :memcached_instance, :rest_client, :base_uri, :resource_suffix, :logger, :disable_caching

      def configure
        yield(self)
        @base_uri ||= ""
      end

      def memcached_instance=(servers, options={})
        opts = default_memcached_options.merge(options)
        @memcached_instance ||= Dalli::Client.new(servers, opts)
      end

      def rest_client=(value)
        raise ConfigurationInvalid, 'Invalid value for rest_client' if ![:get,:put,:delete,:post].all? { |m| value.respond_to?(m) }
        @rest_client ||= value
      end

      # Shouldn't be needed as our favourite rest clients are based on httparty, still, added it for opensource reasons
      def base_uri=(value)
        raise ConfigurationInvalid, "Invalid value for base uri, should be a string" if !value.is_a?(String)
        @base_uri ||= value
      end

      def resource_suffix=(value)
        raise ConfigurationInvalid, "Invalid value for resource suffix, should be a string" if !value.is_a?(String)
        @resource_suffix ||= value
      end

      def disable_caching=(value)
        @disable_caching = value
      end

      private

      def default_memcached_options
        {
          expires_in: expiration_time
        }
      end

      def expiration_time
        if defined?(Rails)
          method = "expiration_time_for_#{ Rails.env }"
          return send(method) if defined?(method)
        end

        default_expiration_time
      end

      def expiration_time_for_development
        60.seconds
      end

      def default_expiration_time
        10.minutes
      end

    end
  end
end
