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

### Hooks

``` ruby
class MyClass
  prepend GenericWorker

  before do
    puts "Before processing"
  end

  def work(message)
    puts "Working with #{message}"
  end

end

MyClass.execute("my class")
# => Before processing
# => Working with my class
```

### Serializers

``` ruby
class MyClass
  prepend GenericWorker

  serialize loader: ->(message){ JSON.parse(message) },
            dumper: ->(message){ JSON.generate(message) }

  def work(message)
    one, two = message
    puts "Message is serialized and deserialized correctly"
    puts "one: #{one}, two: #{two}"
  end

end

MyClass.execute([1, "foo"])
# => Message is serialized and deserialized correctly
# => one: 1, two: foo
```

``` ruby
class MyClass
  prepend GenericWorker

  serialize GenericSerializer.new

  def work(message)
    class, active_record_object = message
    puts "Classes can be passed: #{class.name} - #{class.class}"
    puts "Active record object can be passed too: #{active_record_object}"
  end
end

MyClass.execute([String, User.find(1)])
# => Classes can be passed: String - Class
# => Active record object can be passed too: <User#1 ...>
```

### Helpers

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
