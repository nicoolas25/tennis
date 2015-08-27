module GenericWorker
  def self.prepended(base)
    base.extend DSL
  end

  def work(message)
    deserialized_message = _deserialize(message)
    _process_before_hooks(deserialized_message)
    super(deserialized_message)
  end

  protected

  def _deserialize(message)
    loader = self.class._serializers[:loader]
    if loader.kind_of?(Proc)
      instance_exec(message, &loader)
    elsif loader.respond_to?(:load)
      loader.load(message)
    else
      fail "Unexpected deserializer, it must be a Proc or respond to #load"
    end
  end

  def _process_before_hooks(message)
    self.class._before_hooks.each do |hook|
      _execute_hook(hook, [message])
    end
  end

  def _execute_hook(hook, arguments)
    if hook.kind_of?(Proc)
      instance_exec(*arguments, &hook)
    else
      __send__(hook, *arguments)
    end
  end

  module DSL

    def before(symbol = nil, &block)
      if block_given?
        _before_hooks << block
      elsif symbol
        _before_hooks << symbol
      end
    end

    def serialize(loader:)
      _serializers[:loader] = loader
    end

    def _before_hooks
      @_before_hooks ||= []
    end

    def _serializers
      @_serializers ||= Hash.new(->(message){ message })
    end

  end
end
