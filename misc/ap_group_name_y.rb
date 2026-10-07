lines = ARGF.readlines
puts "# //misc/ap_group_name_y.rb"
lines.each do |line|
  next if line.chomp.empty?
  puts line
  puts "y"
end
