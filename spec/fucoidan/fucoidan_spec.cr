require "../spec_helper"

def ipadic()
  return ENV["MECAB_IPADIC"]? || `mecab-config --dicdir`.chomp() + "/ipadic"
end

def mecab_version()
  return ENV["MECAB_VERSION"]? || `mecab --version`.rstrip().gsub("mecab of ", "")
end

def initialize_fucoidan(arg)
  return Fucoidan::Fucoidan.new("-d #{ipadic()} #{arg}")
end

describe Fucoidan, "#general" do
  it "initializes successfully" do
    f = Fucoidan::Fucoidan.new()
  end

  it "refuses invalid options" do
    expect_raises(MeCabError) {
      f = Fucoidan::Fucoidan.new("--this-option-is-not-defined")
    }
  end

  it "returns MeCab version" do
    expected = mecab_version()
    Fucoidan::Fucoidan.mecab_version().should eq(expected)
  end
end

describe Fucoidan, "#parse" do
  it "parses into string" do
    sentence = "すもももももももものうち"
    expected = "すもも も もも も もも の うち"

    f = initialize_fucoidan("-O wakati")
    f.parse(sentence).rstrip().should eq(expected)
  end

  it "parses into string with features" do
    sentence = "すもももももももものうち"
    expected = "すもも\t名詞,一般,*,*,*,*,すもも,スモモ,スモモ\nも\t助詞,係助詞,*,*,*,*,も,モ,モ\nもも\t名詞,一般,*,*,*,*,もも,モモ,モモ\nも\t助詞,係助詞,*,*,*,*,も,モ,モ\nもも\t名詞,一般,*,*,*,*,もも,モモ,モモ\nの\t助詞,連体化,*,*,*,*,の,ノ,ノ\nうち\t名詞,非自立,副詞可能,*,*,*,うち,ウチ,ウチ\nEOS\n"

    f = initialize_fucoidan("")
    f.parse(sentence).should eq(expected)
  end

  it "parses into node with block" do
    sentence = "すもももももももものうち"
    expected = "すもも も もも も もも の うち".split(" ")

    f = initialize_fucoidan("")
    a = [] of Node
    f.parse(sentence) { |node| a << node }

    a.first.bos?.should be_true
    a.last.eos?.should be_true

    a = a.select { |node| node.nor? }
         .map { |node| node.surface }
    a.should eq(expected)
  end

  it "parses into node with enumerable" do
    sentence = "すもももももももものうち"
    expected = "すもも も もも も もも の うち".split(" ")

    f = initialize_fucoidan("")
    a = f.enum_parse(sentence).to_a()

    a.first.bos?.should be_true
    a.last.eos?.should be_true

    a = a.select { |node| node.nor? }
         .map { |node| node.surface }
    a.should eq(expected)
  end
end
