require "ostruct"

class PublisherMock
  def initialize
    @bunny = OpenStruct.new
  end

  def publish(*args)
  end
end
