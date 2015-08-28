This small library is intended to help creating asynchronous jobs
using Ruby and RabbitMQ via the Sneakers gem.

## Features

- Hooks: `.before(symbol, &block)`
- Serializers: `.serialize(loader:)`
- Helpers for defering method calls: `object.defer.method(*arguments)`

**Extra**

- A `GenericSerializer` handling classes and ActiveRecord objects

## Examples

Those examples are what we wish to achieve.

The name of the queue is the name of the class by default and can be reset
using sneakers' `.from_queue` method.

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

MyClass.execute("my class")
# => Before processing
# => Working with my class
```

### Serializers

You can provide a Proc for the loader and/or the dumper keywords.
The dumper will be used when

``` ruby
class MyClass
  include GenericWorker

  serialize loader: ->(message){ JSON.parse(message) },
            dumper: ->(message){ JSON.generate(message) }

  work |message|
    one, two = message
    puts "Message is serialized and deserialized correctly"
    puts "one: #{one}, two: #{two}"
    ack!
  end
end

MyClass.execute([1, "foo"])
# => Message is serialized and deserialized correctly
# => one: 1, two: foo
```

``` ruby
class MyClass
  include GenericWorker

  serialize GenericSerializer.new

  work |message|
    klass, active_record_object = message
    puts "Classes can be passed: #{klass.name} - #{klass.class}"
    puts "Active record object can be passed too: #{active_record_object}"
    ack!
  end
end

MyClass.execute([String, User.find(1)])
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
