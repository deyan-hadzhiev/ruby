#challenge 3

class Object
  def thread *args
    args.reduce(self) do |result, next_proc| 
      next_proc.class == Symbol ? result.send(next_proc) : result = next_proc.(result)
    end
  end
end