module Constants
  EPS = 1e-6.freeze
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