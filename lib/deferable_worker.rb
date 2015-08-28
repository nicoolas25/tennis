require "generic_worker"
require "generic_serializer"

module DeferableWorker
  def self.included(base)
    base.extend DSL
    base.prepend GenericWorker
    base.serialize GenericSerializer.new
  end

  def work(message)
    receiver, method, arguments = message
    result = receiver.__send__(method, *arguments)
    instance_exec(result, &self.class._on_success)
  rescue => exception
    instance_exec(message, exception, &self.class._on_error)
  end

  def defer
    DeferAction.new(self.class, self)
  end

  class DeferAction
    def initialize(worker_class, receiver)
      @worker_class = worker_class
      @receiver = receiver
      @methods = receiver.methods(false).map(&:to_s)
    end

    def method_missing(name, *arguments, &block)
      if @methods.include?(name.to_s)
        @worker_class.execute([@receiver, name, arguments])
      else
        fail "Method '#{name}' isn't available on: #{receiver}"
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
