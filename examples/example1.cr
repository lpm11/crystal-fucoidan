require "fucoidan"

# Segments sentence into words
f = Fucoidan::Fucoidan.new("-O wakati")
puts(f.parse("すもももももももものうち")) # => すもも も もも も もも の うち

# Segments sentence into nodes
f = Fucoidan::Fucoidan.new("")
f.parse("すもももももももものうち") { |node|
  puts("#{node.surface}\t#{node.feature}")
}

# Extract noun words
words = f.enum_parse("すもももももももものうち")
         .select { |node| node.feature.starts_with?("名詞") }
         .map { |node| node.surface }
puts(words.join(", ")) # => すもも, もも, もも, うち
