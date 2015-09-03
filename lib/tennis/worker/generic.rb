module Tennis
  module Worker
    module Generic

      autoload :BeforeHook, "tennis/worker/generic/before_hook"
      autoload :Serialize,  "tennis/worker/generic/serialize"
      autoload :Options,    "tennis/worker/generic/options"

      def self.included(base)
        base.extend BeforeHook
        base.extend Serialize
        base.extend Options
        base.extend DSL
        base.worker = Class.new do
          @@parent = base

          include Sneakers::Worker
          from_queue @@parent.name

          def work(message)
            message = @@parent._apply_serializer(:load, message)
            @@parent._process_before_hooks(message, self)
            instance_exec(message, &@@parent._work)
          end
        end
      end

      module DSL

        attr_accessor :worker

        def work(&block)
          @_work = block
        end

        def _work
          @_work ||= ->(_){ ack! }
        end

        def execute(message)
          message = _apply_serializer(:dump, message)
          if Tennis.config.async
            publisher_opts = worker.queue_opts.select do |opt_name, _|
              opt_name == :exchange ||
              opt_name == :exchange_type
            end
            publisher = Sneakers::Publisher.new(publisher_opts)
            publisher.publish(message, to_queue: worker.queue_name)
            publisher.instance_variable_get(:@bunny).close
          else
            worker.new.work(message)
          end
        end

      end
    end
  end
end
