class ActiveRecordMock
  attr_reader :id

  def initialize(id = nil)
    @id = id || rand(100)
  end

  def attributes ; end
end
