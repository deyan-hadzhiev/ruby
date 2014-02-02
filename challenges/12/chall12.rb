#Challange 12
module Charlatan
  class DSLObject
    def initialize
      @numbers = []
    end

    def pick_from(enum)
      @original_enum = enum
      @numbers = enum.to_a
    end

    def add(number)
      generic_action(:+, number)
    end

    def subtract(number)
      generic_action(:-, number)
    end

    def multiply_by(number)
      generic_action(:*, number)
    end

    def divide_by(number)
      generic_action(:/, number)
    end

    def you_should_get(number)
      generic_action(:==, number)
      @numbers.all?
    end

    private

    def generic_action(action, number)
      if number == :your_number
        zipped = @numbers.zip @original_enum.to_a
        @numbers = zipped.map { |element| element[0].send(action, element[1]) }
      else
        @numbers.map! { |element| element.send(action, number) }
      end
    end
  end

  class << self
    def trick(&block)
      context = DSLObject.new
      context.instance_eval(&block)
    end
  end
end