require 'singleton'

module Amfetamine
  class Logger
    include Singleton

    def method_missing(method, args)
      args = "[Amfetamine] #{args.to_s}"
      if defined?(Rails)
        Rails.logger.send(method,args)
      # Yeah, temporarilly :-))
      elsif defined?(Merb)
        Merb.logger.send(method,args)
      end
    end
  end
end
