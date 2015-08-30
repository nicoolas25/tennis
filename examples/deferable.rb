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

require "deferable_worker"

require_relative "example"

class Model
  include DeferableWorker

  attr_reader :id

  def initialize(id)
    @id = id
  end

  def method(numbers)
    puts "At #{Time.now}, Model##{id} run method with #{numbers.inspect}\n"
  end

  # Usually the ORM provides this method. Here we're just faking it.
  def self.find(id)
    new(id)
  end

  # Usually the ORM provides this method. Here we're faking it too.
  def attributes
    { id: @id }
  end
end

Example.new(__FILE__, Model).run do |i|
  array = Array.new(5) { 1 + rand(5) }
  print "Press enter to enqueue a random array..." ; gets
  puts "Calling <Model##{i}>.method(#{array.inspect})"
  Model.new(i).defer.method(array)
end
