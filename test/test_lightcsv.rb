# $Id: test_lightcsv.rb 371 2009-04-01 11:41:43Z tommy $
# Copyright:: (C) 2007 TOMITA Masahiro <tommy@tmtm.org>

require "test/unit"
require "lightcsv"
require "tempfile"
require "stringio"

class TC_LightCsv < Test::Unit::TestCase
  def setup()
    @tmpf = Tempfile.new("test")
    @tmpf.puts <<EOS
a,b,c
0,1,2
EOS
    @tmpf.flush
    @tmpf.rewind
  end
  def teardown()
    @tmpf.close!
  end

  def test_foreach()
    expect = [["a","b","c"],["0","1","2"]]
    LightCsv.foreach(@tmpf.path) do |r|
      assert_equal(expect.shift, r)
    end
    assert(expect.empty?)
  end

  def test_readlines()
    expect = [["a","b","c"],["0","1","2"]]
    assert_equal(expect, LightCsv.readlines(@tmpf.path))
  end

  def test_parse()
    expect = [["a","b","c"],["0","1","2"]]
    assert_equal(expect, LightCsv.parse("a,b,c\n0,1,2"))
  end

  def test_open()
    assert_kind_of(LightCsv, LightCsv.open(@tmpf.path))
  end

  def test_open_block()
    ret = LightCsv.open(@tmpf.path) do |csv|
      assert_kind_of(LightCsv, csv)
      12345
    end
    assert_equal(12345, ret)
  end

  def test_initialize()
    assert_kind_of(LightCsv, LightCsv.new(@tmpf))
    assert_kind_of(LightCsv, LightCsv.new("a,b,c"))
  end

  def test_close()
    LightCsv.new(@tmpf).close
    assert(@tmpf.closed?)
  end

  def test_shift()
    csv = LightCsv.new(<<EOS)
a,b,c
1,2,3
EOS
    assert_equal(["a","b","c"], csv.shift)
    assert_equal(["1","2","3"], csv.shift)
    assert_equal(nil, csv.shift)
  end

  def test_shift_crlf()
    csv = LightCsv.new(<<EOS)
a,b,c\r
1,2,3\r
EOS
    assert_equal(["a","b","c"], csv.shift)
    assert_equal(["1","2","3"], csv.shift)
    assert_equal(nil, csv.shift)
  end

  def test_shift_cr()
    csv = LightCsv.new("a,b,c\r1,2,3\r")
    assert_equal(["a","b","c"], csv.shift)
    assert_equal(["1","2","3"], csv.shift)
    assert_equal(nil, csv.shift)
  end

  def test_shift_quote()
    csv = LightCsv.new(<<EOS)
"a","b","c"
"1","2","3"
EOS
    assert_equal(["a","b","c"], csv.shift)
    assert_equal(["1","2","3"], csv.shift)
    assert_equal(nil, csv.shift)
  end

  def test_shift_quote_in_quote()
    csv = LightCsv.new(<<EOS)
"a","""","c"
"1","2""3","4"
EOS
    assert_equal(["a","\"","c"], csv.shift)
    assert_equal(["1","2\"3", "4"], csv.shift)
    assert_equal(nil, csv.shift)
  end

  def test_shift_invalid_dq()
    csv = LightCsv.new(<<EOS)
"a","b","c"
"1",2","3"
EOS
    assert_equal(["a","b","c"], csv.shift)
    assert_raises(LightCsv::InvalidFormat){csv.shift}
  end

  def test_shift_no_dq_end()
    csv = LightCsv.new(<<EOS)
"a","b","c"
"1","2,
EOS
    assert_equal(["a","b","c"], csv.shift)
    assert_raises(LightCsv::InvalidFormat){csv.shift}
  end

  def test_shift_lf_in_data()
    csv = LightCsv.new(<<EOS)
"a","b","c
1","2","3"
EOS
    assert_equal(["a","b","c\n1","2","3"], csv.shift)
  end

  def test_shift_empty_line()
    csv = LightCsv.new(<<EOS)
a,b,c

1,2,3
EOS
    assert_equal(["a","b","c"], csv.shift)
    assert_equal([], csv.shift)
    assert_equal(["1","2","3"], csv.shift)
  end

  def test_shift_empty()
    csv = LightCsv.new("")
    assert_equal(nil, csv.shift)
  end

  def test_shift_comma_end()
    csv = LightCsv.new("a,b,")
    assert_equal(["a","b",""], csv.shift)
  end

  def test_over_bufsize()
    s = StringIO.new(%|"aaa""aaa","bbb\r\n""\r\nbbb","ccc""ccc"\r\n| * 3)
    csv = LightCsv.new(s)
    csv.bufsize = 1
    expect = [["aaa\"aaa","bbb\r\n\"\r\nbbb","ccc\"ccc"]] * 3
    assert_equal expect, csv.readlines
  end

  def test_large_col()
    row = LightCsv.parse('"'+"a"*10000+'"')
    assert_equal [["a"*10000]], row
  end
end
