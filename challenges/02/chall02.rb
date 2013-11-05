#challenge 2

def homogenize(items)
  items.map { |each_item| each_item.class } .uniq.reduce([]) do |accumulator,object_type|
    accumulator << items.select { |each_item| each_item.class == object_type }
  end
end

def homogenize2( items)
  items.group_by(&:class).values
end