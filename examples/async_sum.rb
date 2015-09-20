require "tennis"
require "tennis/backend/memory"

logger = Logger.new(STDOUT)
logger.level = Logger::DEBUG

Tennis.configure do |config|
  config.backend = Tennis::Backend::Memory.new(logger: logger)
  config.logger = logger
end

class Job
  include Tennis::Job

  def sum(*numbers)
    total = numbers.inject(&:+)
    puts "Sum #{numbers} => #{total}"
  end
end

require "tennis/launcher"

# Instanciate a job and add the sum to the job to do.
numbers = (1..9).to_a
10.times do
  Job.new.async.sum(*numbers.sample(3))
end

# Start Tennis.
launcher = Tennis::Launcher.new(concurrency: 2, job_classes: [Job])
launcher.async.start

# Wait 1 seconds and stop Tennis
sleep 1
launcher.async.stop
