require "celluloid" unless $TESTING

module Tennis
  module Actor

    module ClassMethods
      def new_link(*args)
        new(*args)
      end
    end

    module InstanceMethods
      def current_actor
        self
      end

      def after(interval)
      end

      def alive?
        @dead = false unless defined?(@dead)
        !@dead
      end

      def terminate
        @dead = true
      end

      def async
        self
      end
    end

    def self.included(klass)
      if $TESTING
        klass.include InstanceMethods
        klass.extend ClassMethods
      else
        klass.include Celluloid
      end
    end
  end
end
