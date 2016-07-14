#!/usr/bin/env ruby

$LOAD_PATH.unshift(File.dirname(File.realpath(__FILE__)) + '/../lib')

require_relative '../lib/price'

GoodsPrice::ParserUrl.new(GoodsPrice::ParserArgs.new(ARGV).parse).find_goods
