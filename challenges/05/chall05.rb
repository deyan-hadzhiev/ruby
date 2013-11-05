#challange 5

module Enumerable
  def split_up(length:, step: length, pad: [])
    concatenated = to_a + pad.take( length - size % length )
    concatenated.to_enum.each_slice(step).map { |slice| slice.take length }.each { |slice| yield slice if block_given? }.to_a
  end
end