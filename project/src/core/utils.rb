require 'Matrix'

module Constants
  EPS = 1e-6.freeze
end

class Float
  def ==(rhs)
    (self - rhs).abs < Constants::EPS
  end
end

module Combinatorics
  class << self
    def factorial(n)
      1.upto(n).reduce(1, :*)
    end

    def binomial(n, m)
      if m >= 0 and m <= n
        factorial(n) / (factorial(m) * factorial(n - m))
      else
        0
      end
    end

    def bernstein(degree, index, t)
      binomial(degree, index) * (t ** index) * ((1 - t) ** (degree - index))
    end
  end
end

module Transformations
  class << self
    def get_rotational_matrix(axis, angle)
      case axis
        when :x
          Matrix[ [1, 0, 0],
                  [0, Math.cos(angle), - Math.sin(angle)],
                  [0, Math.sin(angle), Math.cos(angle)]]
        when :y
          Matrix[ [Math.cos(angle), 0, Math.sin(angle)],
                  [0, 1, 0],
                  [- Math.sin(angle), 0, Math.cos(angle)]]
        when :z
          Matrix[ [Math.cos(angle), - Math.sin(angle), 0],
                  [Math.sin(angle), Math.cos(angle), 0],
                  [0, 0, 1]]
        else
          Matrix.identity(3)
      end
    end
  end
end