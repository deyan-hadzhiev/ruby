def zig_zag(n)
  zig_zag_table = Array.new(n) do |row| 
    Array.new(n) { |column| row * n + column + 1 }
  end
  0.upto(n - 1).each { |row| zig_zag_table[row].reverse! if row.odd? }
  zig_zag_table
end