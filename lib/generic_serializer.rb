require "json"

class GenericSerializer

  RECOGNIZED_TYPES = {
    active_record: "active_record".freeze,
    class:         "class".freeze,
  }.freeze

  def load(message)
    object = JSON.parse(message)
    deserialize_any(object)
  end

  def dump(message)
    JSON.generate(serialize_any(message))
  end

  private

  def serialize_any(object)
    visit(object) do |type, object|
      case type
      when :object
        object
      when :class
        {
          _type: RECOGNIZED_TYPES[:class],
          _class: object.to_s
        }
      when :active_record
        {
          _type: RECOGNIZED_TYPES[:active_record],
          _class: object.class.to_s,
          _id: object.id,
        }
      else
        fail "Unexpected type: #{type} when visiting object"
      end
    end
  end

  def deserialize_any(object)
    visit(object) do |type, object|
      case type
      when :object
        object
      when :class
        Object.const_get(object["_class"])
      when :active_record
        klass = Object.const_get(object["_class"])
        klass.find(object["_id"])
      else
        fail "Unexpected type: #{type} when visiting object"
      end
    end
  end

  def visit(object, &block)
    visit_any(object, block)
  end

  def visit_any(object, block)
    if object.kind_of?(Array)
      visit_array(object, block)
    elsif is_active_record?(object)
      block.call(:active_record, object)
    elsif is_class?(object)
      block.call(:class, object)
    elsif object.kind_of?(Hash)
      visit_hash(object, block)
    else
      block.call(:object, object)
    end
  end

  def visit_array(array, block)
    array.map { |element| visit_any(element, block) }
  end

  def visit_hash(hash, block)
    hash.each_with_object({}) do |(key, value), new_hash|
      new_hash[key] = visit_any(value, block)
    end
  end

  def is_active_record?(object)
    object.respond_to?(:attributes) ||
    object.is_a?(Hash) && object["_type"] == RECOGNIZED_TYPES[:active_record]
  end

  def is_class?(object)
    object.is_a?(Class) ||
    object.is_a?(Hash) && object["_type"] == RECOGNIZED_TYPES[:class]
  end

end
