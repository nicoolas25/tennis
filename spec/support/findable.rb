class Findable
  attr_reader :id

  def initialize(id)
    @id = id
  end

  def ==(other)
    other.is_a?(self.class) && other.id == @id
  end

  def self.find(id)
    new(id)
  end
end
