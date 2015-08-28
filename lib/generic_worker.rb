require "sneakers"

module GenericWorker
  def self.included(base)
    base.extend DSL
    base.const_set(:Worker, Class.new do
      @@parent = base

      include Sneakers::Worker

      from_queue @@parent.name

      def work(message)
        message = @@parent._deserialize(message)
        @@parent._process_before_hooks(message, self)
        instance_exec(message, &@@parent._work)
      end
    end)
  end

  module DSL

    def before(&block)
      if block_given?
        _before_hooks << block
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

    def work(&block)
      @_work = block
    end

    def execute(message)
      message = _serialize(message)
      if GenericWorker.async
        publisher_opts = self::Worker.queue_opts.slice(:exchange, :exchange_type)
        publisher = Sneakers::Publisher.new(publisher_opts)
        publisher.publish(message, to_queue: self::Worker.queue_name)
        publisher.instance_variable_get(:@bunny).close
      else
        self::Worker.new.work(message)
      end
    end

    def _process_before_hooks(message, worker)
      _before_hooks.each do |hook|
        hook.call(message, worker)
      end
    end

    def _serialize(message)
      dumper = _serializers[:dumper]
      if dumper.kind_of?(Proc)
        dumper.call(message)
      elsif dumper.respond_to?(:dump)
        dumper.dump(message)
      else
        fail "Unexpected serializer, it must be a Proc or respond to #dump"
      end
    end

    def _deserialize(message)
      loader = _serializers[:loader]
      if loader.kind_of?(Proc)
        loader.call(message)
      elsif loader.respond_to?(:load)
        loader.load(message)
      else
        fail "Unexpected deserializer, it must be a Proc or respond to #load"
      end
    end

    def _before_hooks
      @_before_hooks ||= []
    end

    def _serializers
      @_serializers ||= Hash.new(->(message){ message })
    end

    def _work
      @_work ||= ->(_){ ack! }
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
