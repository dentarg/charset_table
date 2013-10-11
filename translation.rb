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
    @characters[codepoint]
  end

  def character(codepoint)
    hex = "0x#{codepoint}".hex
    [hex].pack("U*")
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

  def codepoint(str)
    str.gsub('U+', '')
  end

  def translate(mapping)
    mapping.strip!
    mapping_parts   = mapping.split("->")

    left_codepoint  = codepoint(mapping_parts[0])
    right_codepoint = codepoint(mapping_parts[1])

    left_character  = @unicode_data.character(left_codepoint)
    right_character = @unicode_data.character(right_codepoint)

    left_character_description  = @unicode_data.lookup(left_codepoint)
    right_character_description = @unicode_data.lookup(right_codepoint)
    [mapping, left_character_description, left_character, '->', right_character, right_character_description]
  end
end

CharsetTable.new
