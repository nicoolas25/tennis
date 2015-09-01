#
# Create a client or a worker showing the serialization process.
#
# To run this example you should start a worker, then a client in a separate
# shell. Of course you'll also need a running RabbitMQ server.
#
# Use RABBITMQ_URL environment variable if you need to customize the RabbitMQ
# address.
#

$LOAD_PATH.unshift("./lib")

require "json"
require "tennis"

require_relative "example"

class SumWorker
  include Tennis::Worker::Generic

  serialize loader: ->(message){ JSON.parse(message) },
            dumper: ->(message){ JSON.generate(message) }

  work do |int_array|
    sum = int_array.inject(0, &:+)
    puts "At #{Time.now} I received an array. Sum of its elements is: #{sum}"
    ack!
  end
end

Example.new(__FILE__, SumWorker).run do
  array = Array.new(5) { 1 + rand(5) }
  print "Press enter to enqueue a random array..." ; gets
  puts "Sending #{array.inspect} to the #{SumWorker::Worker.queue_name} queue!"
  SumWorker.execute(array)
end

