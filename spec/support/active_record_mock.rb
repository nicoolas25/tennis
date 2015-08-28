ActiveRecordMock = Struct.new(:id) do
  def attributes ; end

  def self.find(id)
    new(id)
  end
end
