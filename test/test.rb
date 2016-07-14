#!/usr/bin/env ruby

$LOAD_PATH.unshift(File.dirname(File.realpath(__FILE__)) + '/../lib')

require_relative '../lib/price'

puts GoodsProber::ParserArgs.new(ARGV).parse
