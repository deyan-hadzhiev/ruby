class Spy < Object
  class Error < NoMethodError
  end

  def method_missing(name, *args, &block)
    begin
      @called_methods << name
      @instanced_obj.send(name, *args, &block)
    rescue NoMethodError
      raise Spy::Error
    end
  end

  def calls
    @called_methods
  end

  def initialize(object)
    @called_methods = []
    @instanced_obj = object
  end
end
