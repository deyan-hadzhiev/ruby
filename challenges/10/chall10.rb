#challenge 10

class String
  def longest_sequence
    sequences = {}
    rest = self
    while rest != ""
      #some extra brackets in the match call, but ruby didn't except it otherwise
      regex_result = rest.match(/(?<sequence>(?<ch>.)\k<ch>*)(?<rest>.*)/)
      result_length = regex_result[:sequence].length
      if sequences.empty? or sequences.values[0] == result_length
        sequences[regex_result[:ch]] = result_length
      elsif sequences.values[0] < result_length
        sequences.clear
        sequences[regex_result[:ch]] = result_length
      end
      rest = regex_result[:rest]
    end
    sequences.keys
  end
end