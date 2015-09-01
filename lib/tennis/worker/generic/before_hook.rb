module Tennis::Worker::Generic::BeforeHook
  def before(&block)
    if block_given?
      _before_hooks << block
    end
  end

  def _process_before_hooks(message, worker)
    _before_hooks.each do |hook|
      hook.call(message, worker)
    end
  end

  def _before_hooks
    @_before_hooks ||= []
  end
end
