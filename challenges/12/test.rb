require '.\chall12.rb'

Charlatan.trick do
  pick_from 1..10
  multiply_by 2
  multiply_by 5
  divide_by :your_number
  subtract 7
  you_should_get 3
end