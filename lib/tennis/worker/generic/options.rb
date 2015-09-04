module Tennis::Worker::Generic::Options
  SNEAKER_QUEUE_OPTIONS = %i(exchange).freeze

  def set_option(symbol, value)
    if symbol == :queue_name
      worker.from_queue(value, worker.queue_opts)
    else
      options[symbol] = value
      if SNEAKER_QUEUE_OPTIONS.include?(symbol)
        worker.queue_opts[symbol] = value
      end
    end
  end

  def options
    @_options ||= {}
  end
end

