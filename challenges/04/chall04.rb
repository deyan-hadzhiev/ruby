#challange 4
def partition(number)
  (0..number/2).to_a.zip (number/2..number).to_a.reverse
end