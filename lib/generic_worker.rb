require "sneakers"

module GenericWorker
  def self.prepended(base)
    base.extend DSL
    base.include Sneakers::Worker
    base.from_queue base.name

    base.class_eval do
      def initialize(queue = nil, pool = nil, opts= {})
        super(queue, pool, opts) unless opts.delete(:sync_work)
      end
    end
  end

  def work(message)
    deserialized_message = _deserialize(message)
    _process_before_hooks(deserialized_message)
    super(deserialized_message)
  end

  protected

  def _serialize(message)
    dumper = self.class._serializers[:dumper]
    if dumper.kind_of?(Proc)
      instance_exec(message, &dumper)
    elsif dumper.respond_to?(:dump)
      dumper.dump(message)
    else
      fail "Unexpected deserializer, it must be a Proc or respond to #load"
    end
  end

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

    def serialize(object = nil, loader: nil,  dumper: nil)
      if object
        _serializers[:loader] = object if object.respond_to?(:load)
        _serializers[:dumper] = object if object.respond_to?(:dump)
      else
        _serializers[:loader] = loader if loader
        _serializers[:dumper] = dumper if dumper
      end
    end

    def execute(message)
      if GenericWorker.async
        publisher_opts = @queue_opts.slice(:exchange, :exchange_type)
        publisher = Sneakers::Publisher.new(publisher_opts)
        publisher.publish(message, to_queue: @queue_name)
        publisher.instance_variable_get(:@bunny).close
      else
        new.work(message)
      end
    end

    def _before_hooks
      @_before_hooks ||= []
    end

    def _serializers
      @_serializers ||= Hash.new(->(message){ message })
    end

  end

  public

  def self.async
    @async
  end

  def self.async=(boolean)
    @async = boolean
  end

  async = true

end
