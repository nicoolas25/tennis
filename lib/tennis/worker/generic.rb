module Tennis
  module Worker
    module Generic

      autoload :BeforeHook, "tennis/worker/generic/before_hook"
      autoload :Serialize,  "tennis/worker/generic/serialize"

      def self.included(base)
        base.extend BeforeHook
        base.extend Serialize
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

        def work(&block)
          @_work = block
        end

        def _work
          @_work ||= ->(_){ ack! }
        end

        def execute(message)
          message = _apply_serializer(:dump, message)
          if Tennis.config.async
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

      end
    end
  end
end
