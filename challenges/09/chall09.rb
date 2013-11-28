#challenge 09
class Memoizer < BasicObject
  def initialize(object)
    @instanced_object = object
    @returned_values = {}
  end

  def method_missing(name, *args, &block)
    if block
      @instanced_object.send(name, *args, &block)
    else
      @returned_values[name] = @instanced_object.send(name, *args) if @returned_values[name] == nil
      @returned_values[name]
    end
  end
end