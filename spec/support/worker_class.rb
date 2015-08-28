class SerializeWorkerClass
  prepend GenericWorker

  attr_reader :result

  def work(message)
    @result = message + (@before || 0)
    ack!
  end
end

class BeforeWorkerClass
  prepend GenericWorker

  attr_reader :result

  def work(message)
    ack!
  end

  private

  def run_me_before(message)
    @result = [@result, "run_me_before"].compact.join(" ")
  end
end
