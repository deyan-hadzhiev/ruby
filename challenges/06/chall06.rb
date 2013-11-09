#challange 06

class Term
  attr_accessor :coefficient, :degree
  def initialize(coefficient, degree)
    @coefficient = coefficient
    @degree = degree
  end

  def to_s
    @coefficient.zero? ? '' : sign + coeff + variable + ' '
  end

  private
  def sign
    @coefficient > 0 ? '+ ' : '- '
  end

  def coeff
    @coefficient.abs == 1 && @degree != 0 ? '' : @coefficient.abs.to_s
  end

  def variable
    case degree
      when 0 then ''
      when 1 then 'x'
      else "x^#{@degree}"
    end
  end
end

class Polynomial
  def initialize(coefficient_array)
    @polynomial = Array.new(coefficient_array.size) do |index| 
      Term.new(coefficient_array[index], coefficient_array.size - index - 1)
    end
  end

  def to_s
    if @polynomial.all? { |term| term.coefficient.zero? }
      '0'
    else
      formated = @polynomial.map { |term| term.to_s }.join
      stripped = formated.strip
      stripped[0] == '+' ? stripped[2..-1] : stripped
    end
  end
end