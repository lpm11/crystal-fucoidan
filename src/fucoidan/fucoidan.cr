require "mecab"

module Fucoidan
  include MeCab

  class Node
    getter :surface
    getter :feature
    getter :id
    getter :length
    getter :rlength
    getter :rcAttr
    getter :lcAttr
    getter :posid
    getter :char_type
    getter :stat
    getter :isbest
    getter :alpha
    getter :beta
    getter :prob
    getter :wcost
    getter :cost

    @id        : UInt32
    @length    : UInt16
    @rlength   : UInt16
    @rcAttr    : UInt16
    @lcAttr    : UInt16
    @posid     : UInt16
    @char_type : UInt8
    @stat      : UInt8
    @isbest    : Bool
    @alpha     : Float32
    @beta      : Float32
    @prob      : Float32
    @wcost     : Int16
    @cost      : Int64

    def initialize(node_ptr : LibMeCab::MeCab_Node_T*)
      @node_ptr  = node_ptr

      @surface   = String.new(node_ptr.value.surface.to_slice(node_ptr.value.length.to_i32()))
      @feature   = String.new(node_ptr.value.feature)
      @id        = node_ptr.value.id
      @length    = node_ptr.value.length
      @rlength   = node_ptr.value.rlength
      @rcAttr    = node_ptr.value.rcAttr
      @lcAttr    = node_ptr.value.lcAttr
      @posid     = node_ptr.value.posid
      @char_type = node_ptr.value.char_type
      @stat      = node_ptr.value.stat
      @isbest    = node_ptr.value.isbest == 1
      @alpha     = node_ptr.value.alpha
      @beta      = node_ptr.value.beta
      @prob      = node_ptr.value.prob
      @wcost     = node_ptr.value.wcost
      @cost      = node_ptr.value.cost
    end

    def nor?()
      return @stat == LibMeCab::MECAB_NOR_NODE
    end

    def normal?()
      nor?()
    end

    def bos?()
      return @stat == LibMeCab::MECAB_BOS_NODE
    end

    def eos?()
      return @stat == LibMeCab::MECAB_EOS_NODE
    end

    def unk?()
      return @stat == LibMeCab::MECAB_UNK_NODE
    end

    def eon?()
      return @stat == LibMeCab::MECAB_EON_NODE
    end

    def to_s()
      return [
        "@node_ptr=#{@node_ptr.address}",
        "@stat=#{@stat}",
        "@surface=#{@surface}",
        "@feature=#{@feature}",
      ].join(" ")
    end

    def inspect()
      to_s()
    end
  end

  class NodeEnumerator
    include Enumerable(Node)

    def initialize(lattice : LibMeCab::MeCab_Lattice_T*)
      @lattice = lattice
    end

    def each
      node_ptr = LibMeCab.mecab_lattice_get_bos_node(@lattice)

      while (!node_ptr.null?)
        yield Node.new(node_ptr)
        node_ptr = node_ptr.value.next
      end
    end
  end

  class Fucoidan
    def initialize(args="")
      @model = LibMeCab.mecab_model_new2(args)
      if (@model.null?)
        raise MeCabError.new("Could not initialize model (at mecab_model_new2)")
      end

      @tagger = LibMeCab.mecab_model_new_tagger(@model)
      if (@tagger.null?)
        raise MeCabError.new("Could not initialize tagger (at mecab_model_new_tagger)")
      end

      @lattice = LibMeCab.mecab_model_new_lattice(@model)
      if (@lattice.null?)
        raise MeCabError.new("Could not initialize lattice (at mecab_model_new_lattice)")
      end
    end

    def finalize()
      LibMeCab.mecab_lattice_destroy(@lattice) if (@lattice && !@lattice.null?)
      LibMeCab.mecab_destroy(@tagger)          if (@tagger && !@tagger.null?)
      LibMeCab.mecab_model_destroy(@model)     if (@model && !@model.null?)
    end

    def parse(text : String) : String
      check()

      LibMeCab.mecab_lattice_set_sentence(@lattice, text)
      LibMeCab.mecab_parse_lattice(@tagger, @lattice)
      result = LibMeCab.mecab_lattice_tostr(@lattice)

      return String.new(result)
    end

    def parse(text : String, &block : Node ->)
      enum_parse(text).each { |node| yield node }
    end

    def enum_parse(text : String) : NodeEnumerator
      check()

      LibMeCab.mecab_lattice_set_sentence(@lattice, text)
      LibMeCab.mecab_parse_lattice(@tagger, @lattice)

      return NodeEnumerator.new(@lattice)
    end

    def self.mecab_version() : String
      return String.new(LibMeCab.mecab_version())
    end

    private def check()
      check_model()
      check_tagger()
      check_lattice()
    end

    private def check_model()
      raise FucoidanError.new("MeCab model not initialized!") if (!@model || @model.null?)
    end

    private def check_tagger()
      raise FucoidanError.new("MeCab tagger not initialized!") if (!@tagger || @tagger.null?)
    end

    private def check_lattice()
      raise FucoidanError.new("MeCab lattice not initialized!") if (!@lattice || @lattice.null?)
    end
  end

  class MeCabError < Exception
  end

  class FucoidanError < Exception
  end
end
