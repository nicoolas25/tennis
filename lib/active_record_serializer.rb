require "json"

class ActiveRecordSerializer
  def load(message)
  end

  def dump(receiver, *arguments)
    { receiver: serialize(receiver),
      arguments: serialize_array(arguments) }.to_json
  end

  private

  def serialize_any(object)
    if object.kind_of?(Array)
      serialize_array(object)
    elsif object.kind_of?(Hash)
      serialize_hash(object)
    elsif is_active_record?(object)
      serialize(object)
    else
      object
    end
  end

  def serialize_array(array)
    array.map { |element| serialize_any(element) }
  end

  def serialize_hash(hash)
    hash.each_with_object({}) do |(key, value), serialized_hash|
      serialized_hash[key] = serialize_any(value)
    end
  end

  def serialize(active_record_object)
    { _class: active_record_object.class,
      _id: active_record_object.id }
  end

  def is_active_record?(object)
    object.respond_to?(:attributes)
  end

end
