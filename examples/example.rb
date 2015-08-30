require "optparse"
require "sneakers/runner"

class Example
  def initialize(filename, klass)
    @filename = filename
    @klass = klass
  end

  def run(&client_code)
    configure_workers
    parse_options
    if @options[:client]
      start_client(client_code)
    elsif @options[:worker]
      start_worker
    end
  end

  protected

  def configure_workers
    GenericWorker.async = true
    Sneakers.configure(exchange: "example", workers: 1)
    Sneakers.logger.level = Logger::WARN
  end

  def start_client(block, i = 1)
    block.call(i)
    start_client(block, i + 1)
  rescue Interrupt
    puts "Exiting the client"
  end

  def start_worker
    Sneakers::Runner.new([@klass::Worker]).run
  end

  def parse_options
    @options = {}
    OptionParser.new do |opts|
      opts.banner = "Usage: #{@filename}"
      opts.on("-c", "--client", "Run the client") { @options[:client] = true }
      opts.on("-w", "--worker", "Run the worker") { @options[:worker] = true }
    end.parse!
  end
end
