module Tennis
  module Worker
    module Deferable

      autoload :Action, "tennis/worker/deferable/action"

      def self.included(base)
        base.extend DSL
        base.include Worker::Generic
        base.serialize Serializer::Generic.new
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
        Action.new(self.class, self)
      end

      module DSL

        def defer
          Action.new(self, self)
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
  end
end
