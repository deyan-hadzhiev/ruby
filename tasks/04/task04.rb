# task 04
module Asm
  module Constants
    REGISTERS = {
      ax: :'ax',
      bx: :'bx',
      cx: :'cx',
      dx: :'dx',
    }.freeze

    REGULAR_OPERATIONS = {
      mov: :'mov',
      inc: :'inc',
      dec: :'dec',
      cmp: :'cmp',
    }.freeze

    JUMP_OPERATIONS = {
      label: :'label',
      jmp:   :'jmp',
      je:    :'==',
      jne:   :'!=',
      jl:    :'<',
      jle:   :'<=',
      jg:    :'>',
      jge:   :'>=',
    }.freeze
  end

  class QueueManager
    include Constants

    REGISTERS.each do |register_name, register_symbol|
      define_method register_name do
        register_symbol
      end
    end

    REGULAR_OPERATIONS.each do |operation_name, operation|
      define_method operation_name do |*arguments|
        @operations_queue << [operation, arguments]
      end
    end

    JUMP_OPERATIONS.each do |operation_name, operation|
      define_method operation_name do |argument|
        @operations_queue << [operation, argument]
      end
    end

    def method_missing(name)
      name
    end

    def initialize
      @operations_queue = []
    end

    def result
      assembler = Evaluator.new @operations_queue
      assembler.evaluate
      assembler.result
    end
  end

  class Evaluator
    include Constants

    def initialize(operations)
      @operation = operations.select { |operation| operation[0] != :label}
      @labels = {}
      operations.each_index do |index|
        if operations[index][0] == :label then
          @labels[operations[index][1]] = index - @labels.count
        end
      end
      @cmp_result = 0
      @registers = {ax: 0, bx: 0, cx: 0, dx: 0}
    end

    def evaluate
      current = 0
      while (current < @operation.count) do
        if regular_operation? @operation[current][0] then
          operation @operation[current][0], *@operation[current][1]
          current += 1
        else
          current = jump @operation[current][0], @operation[current][1], current
        end
      end
    end

    def result
      @registers.values
    end

    private

    def operation(symbol, register, value = 1)
      value = @registers[value] if register? value
      case symbol
        when :mov then @registers[register] = value
        when :inc then @registers[register] += value
        when :dec then @registers[register] -= value
        when :cmp then @cmp_result = @registers[register] <=> value
      end
    end

    def jump(symbol, label, current)
      jump = symbol == :jmp ? true : @cmp_result.send(symbol, 0)
      if jump
        is_number?(label) ? label : @labels[label]
      else
        current + 1
      end
    end

    def regular_operation?(symbol)
      REGULAR_OPERATIONS.keys.include? symbol
    end

    def is_number?(object)
      true if Float(object) rescue false
    end

    def register?(symbol)
      REGISTERS.keys.include? symbol
    end
  end

  class << self
    def asm(&block)
      manager = QueueManager.new
      manager.instance_eval &block
      manager.result
    end
  end
end