This small library is intended to help creating asynchronous jobs
using Ruby and RabbitMQ via the Sneakers gem.

<a target="_blank" href="https://travis-ci.org/nicoolas25/tennis"><img src="https://travis-ci.org/nicoolas25/tennis.svg?branch=master" /></a>
<a target="_blank" href="https://codeclimate.com/github/nicoolas25/tennis"><img src="https://codeclimate.com/github/nicoolas25/tennis/badges/gpa.svg" /></a>
<a target="_blank" href="https://codeclimate.com/github/nicoolas25/tennis/coverage"><img src="https://codeclimate.com/github/nicoolas25/tennis/badges/coverage.svg" /></a>
<a target="_blank" href="https://rubygems.org/gems/tennis-jobs"><img src="https://badge.fury.io/rb/tennis-jobs.svg" /></a>

## Features

- Hooks: `.before(symbol, &block)`
- Serializers: `.serialize(loader:)`
- Helpers for defering method calls: `object.defer.method(*arguments)`

**Extra**

- A `GenericSerializer` handling classes and ActiveRecord objects

## Configuration

The background job require a group of processes to handle the tasks you want to
do asynchronously. Tennis uses YAML configuration file in order to launch thoses
processes.

``` yaml
# tennis.conf.yml
group1:
  exchange: "default"
  workers: 1
  classes:
    - "Scope::MyClass"
    - "Scope::Model"
group2:
  exchange: "important"
  workers: 10
  classes:
    - "Only::ImportantWorker"
```

Here we see two groups of worker. Each group can be launch with the `tennis`
command:

    $ bundle exec tennis group1

The `workers` options is directly given to sneakers, it will determine the
number of subprocesses that will handle the messages, the level of parallelism.

The classes are the classes that will receive your `send_work` or `defer` calls
but we'll see that later...

Also it is possible to add options directly in your workers:

``` ruby
module WorkerHelpers
  BeforeFork = -> { ActiveRecord::Base.connection_pool.disconnect! rescue nil }
  AfterFork = -> { ActiveRecord::Base.establish_connection }
end

class MyClass
  include GenericWorker

  set_option :before_fork, WorkerHelpers::BeforeFork
  set_option :after_fork, WorkerHelpers::AfterFork
  set_option :handler, Sneakers::Handlers::MaxretryWithoutErrors

  work do |message|
    MyActiveRecordModel.create(message: message)
  end
end
```

In this example I use constants to store the Proc options. This is because
having different options for the workers of a same group isn't possible. By
using this constant, I can have another worker with those same options and put
it in the same group.

## Examples

Those examples are what we wish to achieve.

The name of the queue is the name of the class by default and can be reset
using sneakers' `YourClass.worker.from_queue` method.

### Hooks

``` ruby
class MyClass
  include GenericWorker

  before do
    puts "Before processing"
  end

  work do |message|
    puts "Working with #{message}"
    ack!
  end
end

MyClass.send_work("my class")
# => Before processing
# => Working with my class
```

### Serializers

You can provide a Proc for the loader and/or the dumper keywords.
The dumper will be used when calling `MyClass.send_work(message)` receiving
the `message` as argument. It should return a string. The loader will be
used when the message is poped from the RabbitMQ queue.

``` ruby
class MyClass
  include GenericWorker

  serialize loader: ->(message){ JSON.parse(message) },
            dumper: ->(message){ JSON.generate(message) }

  work do |message|
    one, two = message
    puts "Message is serialized and deserialized correctly"
    puts "one: #{one}, two: #{two}"
    ack!
  end
end

MyClass.send_work([1, "foo"])
# => Message is serialized and deserialized correctly
# => one: 1, two: foo
```

``` ruby
class MyClass
  include GenericWorker

  serialize GenericSerializer.new

  work do |message|
    klass, active_record_object = message
    puts "Classes can be passed: #{klass.name} - #{klass.class}"
    puts "Active record object can be passed too: #{active_record_object}"
    ack!
  end
end

MyClass.send_work([String, User.find(1)])
# => Classes can be passed: String - Class
# => Active record object can be passed too: <User#1 ...>
```

### Helpers

Any class method can be defered:

``` ruby
class MyClass
  include DeferableWorker

  def self.my_method(user)
    puts "Running my method on #{user}"
  end
end

MyClass.defer.my_method(User.find(1))
# => Running my method on <User#1 ...>
```

An ActiveRecord::Base instance can be the receiver if it has an `id`:

``` ruby
class MyModel < ActiveRecord::Base
  include DeferableWorker

  def my_method
    puts "Running my method on #{self}"
  end
end

instance = MyModel.find(1)
instance.defer.my_method
# => Running my method on <MyModel#1 ...>
```

Handling errors and results for the deferred methods is via `on_error` and
`on_success` keyword. You must return `ack!` or `reject!` here as in a
Sneakers' `work` method.

``` ruby
class MyModel < ActiveRecord::Base
  include DeferableWorker

  on_error do |exception|
    puts "I just saved the day handling a #{exception}"
    reject!
  end

  def my_method
    puts "Running my method on #{self}"
    raise StandardError
  end
end

instance = MyModel.find(1)
instance.defer.my_method
# => Running my method on <MyModel#1 ...>
# => I just saved the day handling a StandardError
```
