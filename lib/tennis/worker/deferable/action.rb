class Tennis::Worker::Deferable::Action
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
