# ruby task 1

class Integer
  def prime?
    if self <= 1
      false
    elsif self == 2
      true
    else
      2.upto(Math.sqrt(self).ceil).all? { |x| self.remainder(x).nonzero? }
    end
  end

  def prime_factors
    factors = []
    divided = self.abs
    2.upto(abs).select { |x| x.prime? and remainder(x).zero? }.each do |fact|
      factors << fact and divided /= fact while divided.remainder(fact).zero?
    end
    factors
  end

  def harmonic
    raise "ERROR: negative input" if self <= 0
    sum = Rational(0, 1)
    1.upto(self).each { |denominator| sum += Rational(1, denominator) }
    sum
  end

  def digits
    digits_array = [abs % 10]
    remainder = abs / 10
    until remainder == 0
      digits_array << remainder % 10
      remainder /= 10
    end
    digits_array.reverse
  end
end

class Array
  def frequencies
    frequency = {}
    self.each do |element|
      if frequency[element] == nil
        frequency[element] = 1
      else
        frequency[element] += 1
      end
    end
    frequency
  end

  def average
    raise "ERROR: empty array" if empty?
    sum = 0.0
    each { |i| sum += i}
    sum / length
  end

  def drop_every(n)
    raise "ERROR: negative or zero n" if n <= 0
    if length < n then self else take(n - 1) + drop(n).drop_every(n) end
  end

  def combine_with(other)
    if empty?
      other
    elsif other.empty?
      self
    else
      take(1) + other.take(1) + drop(1).combine_with(other.drop 1)
    end
  end
end
