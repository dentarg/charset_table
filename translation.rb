#!/bin/env ruby

require 'csv'
Bundler.require

class UnicodeData
  DATA_FILE = 'UnicodeData.txt'

  def initialize
    @characters = {}
    CSV.foreach(DATA_FILE, { col_sep: ';'}) do |row|
      codepoint   = row[0]
      description = row[1]
      @characters[codepoint] = description
    end
  end

  def lookup(codepoint)
    codepoint.gsub!('U+', '')
    @characters[codepoint]
  end
end

# u = UnicodeData.new
# puts u.lookup("U+0112")
# => CYRILLIC SMALL LETTER A WITH DIAERESIS

class CharsetTable
  DATA_FILE = 'charset_table'

  def initialize
    @unicode_data = UnicodeData.new
    mappings = []
    CSV.foreach(DATA_FILE) do |row|
      mappings += row
    end
    mappings.select! { |mapping| mapping.include?('->') }
    # TODO: handle range mappings too
    mappings.reject! { |mapping| mapping.include?('..') }

    rows = []
    mappings.each do |mapping|
      rows << translate(mapping)
    end
    table = Terminal::Table.new(rows: rows)
    puts table
  end

  def translate(mapping)
    mapping.strip!
    codepoints      = mapping.split("->")
    left_codepoint  = codepoints[0]
    right_codepoint = codepoints[1]
    left_character_description  = @unicode_data.lookup(left_codepoint)
    right_character_description = @unicode_data.lookup(right_codepoint)
    [mapping, left_character_description, right_character_description]
  end
end

CharsetTable.new
