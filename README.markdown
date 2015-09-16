This is a celluloid based background jobs library heavily inspired by [Sidekiq][sidekiq].
The difference is that it allows you to change the backend, Redis, to other ones like RabitMQ.
You can start with something _à la_ [sucker_punch][sucker_punch]: background jobs threaded within the application process
and switch to separated processes later using another backend.

<a target="_blank" href="https://travis-ci.org/nicoolas25/tennis"><img src="https://travis-ci.org/nicoolas25/tennis.svg?branch=master" /></a>
<a target="_blank" href="https://codeclimate.com/github/nicoolas25/tennis"><img src="https://codeclimate.com/github/nicoolas25/tennis/badges/gpa.svg" /></a>
<a target="_blank" href="https://codeclimate.com/github/nicoolas25/tennis/coverage"><img src="https://codeclimate.com/github/nicoolas25/tennis/badges/coverage.svg" /></a>
<a target="_blank" href="https://rubygems.org/gems/tennis-jobs"><img src="https://badge.fury.io/rb/tennis-jobs.svg" /></a>

## Configuration

Install the gem in your Gemfile:

``` ruby
gem "tennis-jobs"
gem "tennis-jobs-redis" # Not available at the moment
```

Configure Tennis in your `config/application.rb` (or any other file):

``` ruby
Tennis.configure do |config|
  config.backend Tennis::Backend::Redis.new(redis_url)

  # require "logger"
  # config.logger = Logger.new(STDOUT)
end
```

Start tennis from the command line:

```
bundle exec tennis --concurrency 4 --require ./config/application.rb --jobs "MyJob,MyOtherJob"

# There is also a shorter equivalent:
# bundle exex tennis -c 4 -r ./config/application.rb -j "MyJob,MyOtherJob"
```

## Usage

``` ruby
MINUTES = 60

class MyJob
  include Tennis::Job

  def my_method(*args)
    puts "=> #{args}.sum = args.inject(0, &:+)"
  end
end

my_job_instance = MyJob.new
my_job_instance.async.my_method(1, 2, 3)

# Will print in your `tennis` process:
# => [1, 2, 3].sum = 6

my_job_instance.async_in(2 * MINUTES).my_method(4, 5, 6)

# Will print, in approximatively two minutes, in your `tennis` process:
# => [4, 5, 6].sum = 15
```

The `my_method`'s arguments can be quite complex depending on your backend support.
The same goes for the `MyJob`'s instance.

With the `Tennis::Backend::Memory` backend, you can use anything and it will be kept as it is.

## Testing

This section is waiting to beeing written.


[sidekiq]: https://github.com/mperham/sidekiq
[sucker_punch]: https://github.com/brandonhilkert/sucker_punch
