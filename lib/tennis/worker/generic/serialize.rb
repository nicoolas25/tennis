module Tennis::Worker::Generic::Serialize
  def serialize(object = nil, loader: nil,  dumper: nil)
    if object
      _serializers[:load] = object if object.respond_to?(:load)
      _serializers[:dump] = object if object.respond_to?(:dump)
    else
      _serializers[:load] = loader if loader
      _serializers[:dump] = dumper if dumper
    end
  end

  def _apply_serializer(serializer_kind, message)
    serializer = _serializers[serializer_kind]
    if serializer.kind_of?(Proc)
      serializer.call(message)
    elsif serializer.respond_to?(serializer_kind)
      serializer.__send__(serializer_kind, message)
    else
      fail "Unexpected (de)serializer, it must be a Proc or respond to ##{kind}"
    end
  end

  def _serializers
    @_serializers ||= Hash.new(->(message){ message })
  end
end
