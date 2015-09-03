module Tennis::Worker::Generic::Options
  def set_option(symbol, value)
    options[symbol] = value
  end

  def options
    @_options ||= {}
  end
end

