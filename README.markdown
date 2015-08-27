This small library is intended to help creating asynchronous jobs
using Ruby and RabbitMQ via the Sneakers gem.

## Features

- Hooks: `.before(symbol, &block)`
- Serializers: `.serialize(loader:)`

## Examples

Those examples are what we wish to achieve.

### Hooks

``` ruby
class MyClass
  include GenericWorker

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
  include GenericWorker

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
