= LightCsv =
CSV パーサ

== 作者 ==

とみたまさひろ <tommy@tmtm.org>

== ライセンス ==

Ruby ライセンス http://www.ruby-lang.org/ja/LICENSE.txt と同等。

== 機能 ==

 * CSV をパースして配列を返す。

== ダウンロード ==

 * http://tmtm.org/downloads/ruby/lightcsv/

== インストール ==

{{{
$ make
$ make test
# make install
}}}

== CSVのパース ==

各レコードはカラムを要素とする配列である。
レコードの区切りは LF,CR,CRLF のいずれか。

以下が csv.rb と異なる。
 * 空行は [nil] ではなく [] になる。
 * 「"」で括られていない空カラムは nil ではなく "" になる。

== 使用例 ==
 * CSVファイルのレコード毎にブロックを繰り返す。
{{{
    LightCsv.foreach(filename){|row| ...}
}}}
   次と同じ。
{{{
    LightCsv.open(filename){|csv| csv.each{|row| ...}}
}}}

 * CSVファイルの全レコードを返す。
{{{
    LightCsv.readlines(filename)  # => [[col1,col2,...],...]
}}}
   次と同じ。
{{{
    LightCsv.open(filename){|csv| csv.map}
}}}

 * CSV文字列のレコード毎にブロックを繰り返す。
{{{
    LightCsv.parse("a1,a2,..."){|row| ...}
}}}
   次と同じ。
{{{
    LightCsv.new("a1,a2,...").each{|row| ...}
}}}

 * CSV文字列の全レコードを返す。
{{{
    LightCsv.parse("a1,a2,...")  # => [[a1,a2,...],...]
}}}
   次と同じ。
{{{
    LightCsv.new("a1,a2,...").map
}}}
