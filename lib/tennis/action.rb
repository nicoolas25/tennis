module Tennis
  class Action

    attr_reader :_receiver

    def initialize(receiver, delay: nil)
      @_receiver = receiver
      @delay = delay
      _create_methods!
    end

    private

    def _create_methods!
      _methods.each do |method|
        self.define_singleton_method(method) do |*arguments|
          _store(job: @_receiver, method: method, args: arguments)
        end
      end
    end

    def _methods
      @_receiver.class.instance_methods(false).map(&:to_s)
    end

    def _store(**kwargs)
      Tennis.config.backend.store(**kwargs.merge(delay: @delay))
    end
  end
end
