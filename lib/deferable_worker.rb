require "generic_worker"
require "generic_serializer"

module DeferableWorker
  def self.included(base)
    base.extend DSL
    base.include GenericWorker
    base.serialize GenericSerializer.new
    define_work_broker(base)
  end

  def self.define_work_broker(base)
    base.work do |message|
      begin
        receiver, method, arguments = message
        result = receiver.__send__(method, *arguments)
        instance_exec(result, &base._on_success)
      rescue => exception
        instance_exec(exception, message, &base._on_error)
      end
    end
  end

  def defer
    DeferAction.new(self.class, self)
  end

  class DeferAction
    def initialize(worker_class, receiver)
      @worker_class = worker_class
      @receiver = receiver
      _create_methods!
    end

    private

    def _create_methods!
      _methods.each do |method|
        self.define_singleton_method(method) do |*arguments|
          @worker_class.execute([@receiver, method, arguments])
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
  end

  module DSL

    def defer
      DeferAction.new(self, self)
    end

    def on_error(&block)
      @_on_error = block
    end

    def on_success(&block)
      @_on_success = block
    end

    def _on_error
      @_on_error || ->(_, _){ reject! }
    end

    def _on_success
      @_on_success || ->(_){ ack! }
    end

  end
end
