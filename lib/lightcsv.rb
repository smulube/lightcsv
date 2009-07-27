# = LightCsv
# CSV parser
#
# $Id: lightcsv.rb 371 2009-04-01 11:41:43Z tommy $
# Copyright:: 2007 (C) TOMITA Masahiro <tommy@tmtm.org>
# License:: Ruby's
# Homepage:: http://tmtm.org/ja/ruby/lightcsv

require "strscan"

# == CSV のパース
# 各レコードはカラムを要素とする配列である。
# レコードの区切りは LF,CR,CRLF のいずれか。
#
# 以下が csv.rb と異なる。
# * 空行は [nil] ではなく [] になる。
# * 「"」で括られていない空カラムは nil ではなく "" になる。
#
# == 例
# * CSVファイルのレコード毎にブロックを繰り返す。
#     LightCsv.foreach(filename){|row| ...}
#   次と同じ。
#     LightCsv.open(filename){|csv| csv.each{|row| ...}}
#
# * CSVファイルの全レコードを返す。
#     LightCsv.readlines(filename)  # => [[col1,col2,...],...]
#   次と同じ。
#     LightCsv.open(filename){|csv| csv.map}
#
# * CSV文字列のレコード毎にブロックを繰り返す。
#     LightCsv.parse("a1,a2,..."){|row| ...}
#   次と同じ。
#     LightCsv.new("a1,a2,...").each{|row| ...}
#
# * CSV文字列の全レコードを返す。
#     LightCsv.parse("a1,a2,...")  # => [[a1,a2,...],...]
#   次と同じ。
#     LightCsv.new("a1,a2,...").map
#
class LightCsv
  include Enumerable

  # == パースできない形式の場合に発生する例外
  # InvalidFormat#message は処理できなかった位置から 10バイト分の文字列を返す。
  class InvalidFormat < RuntimeError; end

  # ファイルの各レコード毎にブロックを繰り返す。
  # ブロック引数はレコードを表す配列。
  def self.foreach(filename, &block)
    self.open(filename) do |f|
      f.each(&block)
    end
  end

  # ファイルの全レコードをレコードの配列で返す。
  def self.readlines(filename)
    self.open(filename) do |f|
      return f.map
    end
  end

  # CSV文字列の全レコードをレコードの配列で返す。
  # ブロックが与えられた場合は、レコード毎にブロックを繰り返す。
  # ブロック引数はレコードを表す配列。
  def self.parse(string, &block)
    unless block
      return self.new(string).map
    end
    self.new(string).each do |row|
      block.call row
    end
    return nil
  end

  # ファイルをオープンして LightCsv オブジェクトを返す。
  # ブロックを与えた場合は LightCsv オブジェクトを引数としてブロックを実行する。
  def self.open(filename, &block)
    f = File.open(filename)
    csv = self.new(f)
    if block
      begin
        return block.call(csv)
      ensure
        csv.close
      end
    else
      return csv
    end
  end

  # LightCsv オブジェクトを生成する。
  # _src_ は String か IO。
  def initialize(src)
    if src.kind_of? String
      @file = nil
      @ss = StringScanner.new(src)
    else
      @file = src
      @ss = StringScanner.new("")
    end
    @buf = ""
    @bufsize = 64*1024
  end
  attr_accessor :bufsize

  # LightCsv オブジェクトに関連したファイルをクローズする。
  def close()
    @file.close if @file
  end

  # 1レコードを返す。データの最後の場合は nil を返す。
  # 空行の場合は空配列([])を返す。
  # 空カラムは「"」で括られているか否かにかかわらず空文字列("")になる。
  def shift()
    return nil if @ss.eos? and ! read_next_data
    cols = []
    while true
      if @ss.eos? and ! read_next_data
        cols << ""
        break
      end
      if @ss.scan(/\"/n)
        until @ss.scan(/((?:\"\"|[^\"])*)\"(,|\r\n|\n|\r|\z)/n)
          read_next_data or raise InvalidFormat, @ss.rest[0,10]
        end
        cols << @ss[1].gsub(/\"\"/n, '"')
      else
        unless @ss.scan(/([^\",\r\n]*)(,|\r\n|\n|\r|\z)/n)
          raise InvalidFormat, @ss.rest[0,10]
        end
        cols << @ss[1]
      end
      break unless @ss[2] == ','
    end
    cols.clear if cols.size == 1 and cols.first.empty?
    cols
  end

  # 各レコード毎にブロックを繰り返す。
  def each()
    while row = shift
      yield row
    end
  end

  # 現在位置以降のレコードの配列を返す。
  def readlines()
    return map
  end

  private

  # 入力がファイルの場合、@bufsize バイト読み込んで、@ss にセットする。
  # 行として不完全な部分は @buf に保持して次回にまわす。
  # ファイルの最後まで達した場合は nil を返す。
  def read_next_data()
    return unless @file && @buf
    while buf = @file.read(@bufsize)
      @buf.concat buf
      if l = @buf.slice!(/\A.*(?:\r\n|\r(.)|\n)/mn) # \r\n の \r だけ読んでしまわないように \r. として、
        if $1
          @buf[0,0] = $1                            # 読みすぎた分を @buf に戻す
          l.chop!
        end
        @ss.string = @ss.rest + l
        return true
      end
    end
    return if @buf.empty?
    @ss.string = @ss.rest + @buf
    @buf = nil
    true
  end
end
