module Tennis
  class Action
    def initialize(receiver, delay: nil)
      @receiver = receiver
      @delay = delay
      _create_methods!
    end

    private

    def _create_methods!
      _methods.each do |method|
        self.define_singleton_method(method) do |*arguments|
          _store(job: @receiver, method: method, args: arguments)
        end
      end
    end

    def _methods
      if @receiver.kind_of?(Class)
        @receiver.methods(false).map(&:to_s)
      else
        @receiver.class.instance_methods(false).map(&:to_s)
      end
    end

    def _store(**kwargs)
      Tennis.config.adapter.store(**kwargs.merge(delay: @delay))
    end
  end
end
