require "sneakers"

module GenericWorker
  def self.included(base)
    base.extend DSL
    base.const_set(:Worker, Class.new do
      @@parent = base

      include Sneakers::Worker

      from_queue @@parent.name

      def work(message)
        message = @@parent._apply_serializer(:load, message)
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
        _serializers[:load] = object if object.respond_to?(:load)
        _serializers[:dump] = object if object.respond_to?(:dump)
      else
        _serializers[:load] = loader if loader
        _serializers[:dump] = dumper if dumper
      end
    end

    def work(&block)
      @_work = block
    end

    def execute(message)
      message = _apply_serializer(:dump, message)
      if GenericWorker.async
        publisher_opts = self::Worker.queue_opts.select do |opt_name, _|
          opt_name == :exchange ||
          opt_name == :exchange_type
        end
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

    def _apply_serializer(serializer_kind, message)
      serializer = _serializers[serializer_kind]
      if serializer.kind_of?(Proc)
        serializer.call(message)
      elsif serializer.respond_to?(serializer_kind)
        serializer.__send__(serializer_kind, message)
      else
        fail "Unexpected (de)serializer, it must be a Proc or respond to ##{kind}"
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

  def self.async
    @async
  end

  def self.async=(boolean)
    @async = boolean
  end

  async = true

end
