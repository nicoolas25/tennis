#
# Create a client or a worker showing the serialization process.
#
# To run this example you should start a worker, then a client in a separate
# shell. Of course you'll also need a running RabbitMQ server.
#
# Use RABBITMQ_URL environment variable if you need to customize the RabbitMQ
# address.
#

require "json"

require_relative "../lib/generic_worker"

GenericWorker.async = true

Sneakers.configure(exchange: "example", workers: 1)
Sneakers.logger.level = Logger::WARN

class SumWorker
  include GenericWorker

  serialize loader: ->(message){ JSON.parse(message) },
            dumper: ->(message){ JSON.generate(message) }

  work do |int_array|
    sum = int_array.inject(0, &:+)
    puts "At #{Time.now} I received an array. Sum of its elements is: #{sum}"
    ack!
  end
end

def start_client
  array = Array.new(5) { 1 + rand(5) }
  print "Press enter to enqueue a random array..." ; gets
  puts "Sending #{array.inspect} to the #{SumWorker::Worker.queue_name} queue!"
  SumWorker.execute(array)
  start_client
rescue Interrupt
  puts "Exiting the client"
end

require "optparse"

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: examples/serializer.rb"
  opts.on("-c", "--client", "Run the client") { options[:client] = true }
  opts.on("-w", "--worker", "Run the worker") { options[:worker] = true }
end.parse!

if options[:client]
  start_client
elsif options[:worker]
  require "sneakers/runner"
  Sneakers::Runner.new([SumWorker::Worker]).run
end
