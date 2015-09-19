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

#
# Manually process the job
#

puts "==== Manually process the job ===="

require "tennis/worker_pool"
require "celluloid/condition"

# Instanciate a job and add the sum to the job to do.
job = Job.new
job.async.sum(1, 2, 3)

# Fetch the task that contains our sum job from Tennis's backend.
task = Tennis.config.backend.receive(job_classes: [Job])

# Create a worker pool to handle the job and make it work on task.
stop = Celluloid::Condition.new
pool = Tennis::WorkerPool.new(stop, concurrency: 2)
pool.async.work(task)

# Stop the pool of workers and wait for it to be stopped properly.
pool.async.stop
stop.wait

#
# Using the Tennis::Launcher
#

puts "==== Using the Tennis::Launcher ===="

require "tennis/launcher"

# Instanciate a job and add the sum to the job to do.
job = Job.new
job.async.sum(2, 3, 4)

# Create start and stop the launcher.
launcher = Tennis::Launcher.new(concurrency: 2, job_classes: [Job])
launcher.async.start
launcher.async.stop
