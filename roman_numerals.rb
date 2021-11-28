require 'ice_nine'
require 'ice_nine/core_ext/object'
require "terminal-table"

class RomanNumerals
  def self.output_roman_numerals
    puts generate_table
  end

  private

  TYPE_MAJOR = "major".deep_freeze
  TYPE_MINOR = "minor".deep_freeze
  TYPE_DIMINISHED = "diminished".deep_freeze
  TYPES = [TYPE_MAJOR, TYPE_MINOR, TYPE_DIMINISHED].deep_freeze
  LYDIAN_TYPES = [TYPE_MAJOR, TYPE_MAJOR, TYPE_MINOR, TYPE_DIMINISHED, TYPE_MAJOR, TYPE_MINOR, TYPE_MINOR].deep_freeze
  LYDIAN_ACCIDENTALS = [0, 0, 0, 1, 0, 0, 0].deep_freeze

  ACCIDENTAL_ORDER = [
    +7,
    +3,
    +6,
    +2,
    +5,
    +1,
    0, # Lydian
    -4, # Ionian
    -7, # Mixolydian
    -3, # Dorian
    -6, # Aeolian
    -2, # Phrygian
    -5, # Locrian
    -1,
    -4,
  ].deep_freeze

  ACCIDENTAL_ORDER_KEY_NAMES = {
    0 => "Lydian",
    -4 => "Ionian",
    7 => "Ionian",
    -7 => "Mixolydian",
    -3 => "Dorian",
    -6 => "Aeolian",
    -2 => "Phrygian",
    -5 => "Locrian",
  }.deep_freeze

  private_constant :TYPE_MAJOR
  private_constant :TYPE_MINOR
  private_constant :TYPE_DIMINISHED
  private_constant :TYPES
  private_constant :LYDIAN_TYPES
  private_constant :ACCIDENTAL_ORDER
  private_constant :ACCIDENTAL_ORDER_KEY_NAMES

  class << self
    def generate_table
      table = Terminal::Table.new
      table.headings = ["Key Name", "1", "2", "3", "4", "5", "6", "7"]
      table.style = {all_separators: true}

      roman_numerals = generate_all_roman_numerals
      ACCIDENTAL_ORDER.zip(roman_numerals).each do |accidental_order, roman_numerals|
        accidental_change = if accidental_order.positive?
                              " (##{accidental_order.abs})"
                            elsif accidental_order.negative?
                              " (b#{accidental_order.abs})"
                            else
                              ""
                            end

        key_name = ACCIDENTAL_ORDER_KEY_NAMES[accidental_order] || "Unknown"
        key_name = key_name + accidental_change

        table << [key_name, *roman_numerals]
      end

      return table
    end

    def generate_all_roman_numerals
      lydian_index = ACCIDENTAL_ORDER.index(0)

      # generate the flattened keys
      types = LYDIAN_TYPES.dup
      accidentals = LYDIAN_ACCIDENTALS.dup
      flattened_result = ACCIDENTAL_ORDER[lydian_index + 1..].map do |degree_change|
        generate_roman_numerals(types, accidentals, degree_change, 4)
      end

      # generate the sharpened keys
      types = LYDIAN_TYPES.dup
      accidentals = LYDIAN_ACCIDENTALS.dup
      sharpened_result = ACCIDENTAL_ORDER[..lydian_index - 1].reverse.map do |degree_change|
        generate_roman_numerals(types, accidentals, degree_change, -4)
      end

      return [
        *sharpened_result.reverse,
        generate_roman_numerals(LYDIAN_TYPES.dup, LYDIAN_ACCIDENTALS.dup, 0, 0),
        *flattened_result,
      ]
    end

    def generate_roman_numerals(types, accidentals, degree_change, rotation)
      types.rotate!(rotation)

      if degree_change.positive?
        change_accidental_index = degree_change.abs - 1
        accidentals[change_accidental_index] += 1
      elsif degree_change.negative?
        change_accidental_index = degree_change.abs - 1
        accidentals[change_accidental_index] -= 1
      end

      roman_numerals = accidentals.zip(types).map.with_index do |accidental_zip_array, index|
        to_roman_numeral(index + 1, *accidental_zip_array)
      end

      return roman_numerals
    end

    def to_roman_numeral(number, accidental, quality)
      result = case number
               when 1
                 "i"
               when 2
                 "ii"
               when 3
                 "iii"
               when 4
                 "iv"
               when 5
                 "v"
               when 6
                 "vi"
               when 7
                 "vii"
               else
                 raise ArgumentError.new("Chord number must be between 1 and 7 inclusive")
               end

      result = case quality
               when TYPE_MAJOR
                 result.upcase
               when TYPE_MINOR
                 result
               when TYPE_DIMINISHED
                 result + "ᵒ"
               else
                 raise ArgumentError.new("Chord quality must be one of: #{TYPES.inspect}")
               end

      result = case accidental
               when -2
                 "bb"
               when -1
                 "b"
               when 0
                 ""
               when 1
                 "#"
               when 2
                 "x"
               else
                 raise ArgumentError.new("Accidental must be between -2 and 2 inclusive")
               end + result

      return result
    end
  end
end
