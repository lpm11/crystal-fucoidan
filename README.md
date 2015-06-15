# crystal-fucoidan [![Build Status](https://travis-ci.org/lpm11/crystal-fucoidan.svg?branch=master)](https://travis-ci.org/lpm11/crystal-fucoidan) [![License](https://img.shields.io/badge/license-MIT-blue.svg)](http://opensource.org/licenses/MIT)
[crystal-mecab](https://github.com/lpm11/crystal-mecab) wrapper.

## Usage
Make Projectfile like this to tell crystal about dependencies.

```
deps do
  github "lpm11/crystal-mecab"
  github "lpm11/crystal-fucoidan"
end
```

Run `crystal deps` enables us to use basic functions of MeCab in crystal like this.

```crystal
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
```

## License
[MIT](http://opensource.org/licenses/MIT)
