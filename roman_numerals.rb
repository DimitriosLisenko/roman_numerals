require 'ice_nine'
require 'ice_nine/core_ext/object'
require "terminal-table"

class RomanNumerals
  def self.output_secondary_chords
    puts generate_secondary_chords_table
  end

  def self.output_borrowed_chords
    puts generate_borrowed_chords_table
  end

  private

  TYPE_MAJOR = "major".deep_freeze
  TYPE_MINOR = "minor".deep_freeze
  TYPE_DIMINISHED = "diminished".deep_freeze
  TYPES = [TYPE_MAJOR, TYPE_MINOR, TYPE_DIMINISHED].deep_freeze
  LYDIAN_TYPES = [TYPE_MAJOR, TYPE_MAJOR, TYPE_MINOR, TYPE_DIMINISHED, TYPE_MAJOR, TYPE_MINOR, TYPE_MINOR].deep_freeze
  LYDIAN_ACCIDENTALS = [0, 0, 0, 1, 0, 0, 0].deep_freeze
  IONIAN_TYPES = [TYPE_MAJOR, TYPE_MINOR, TYPE_MINOR, TYPE_MAJOR, TYPE_MAJOR, TYPE_MINOR, TYPE_DIMINISHED].deep_freeze
  IONIAN_ACCIDENTALS = [0, 0, 0, 0, 0, 0, 0].deep_freeze

  ACCIDENTAL_ORDER = [
    +7,
    +3,
    +6,
    +2,
    +5,
    +1,
    0,
    -4,
    -7,
    -3,
    -6,
    -2,
    -5,
    -1,
    -4,
  ].deep_freeze

  BORROWED_CHORDS_NUMBER_OF_ACCIDENTALS = [0, 2, 4, -1, 1, 3, 5].deep_freeze

  ACCIDENTAL_ORDER_KEY_NAMES = [
    "Sharp Ionian",
    "Sharp Mixolydian",
    "Sharp Dorian",
    "Sharp Aeolian",
    "Sharp Phrygian",
    "Sharp Locrian",
    "Lydian",
    "Ionian",
    "Mixolydian",
    "Dorian",
    "Aeolian",
    "Phrygian",
    "Locrian",
    "Flat Lydian",
    "Flat Ionian",
  ].deep_freeze

  private_constant :TYPE_MAJOR
  private_constant :TYPE_MINOR
  private_constant :TYPE_DIMINISHED
  private_constant :TYPES
  private_constant :LYDIAN_TYPES
  private_constant :LYDIAN_ACCIDENTALS
  private_constant :IONIAN_TYPES
  private_constant :IONIAN_ACCIDENTALS
  private_constant :ACCIDENTAL_ORDER
  private_constant :ACCIDENTAL_ORDER_KEY_NAMES
  private_constant :BORROWED_CHORDS_NUMBER_OF_ACCIDENTALS

  class << self
    def generate_secondary_chords_table
      table = Terminal::Table.new
      table.title = "Secondary Chords"
      headings = IONIAN_TYPES.map.with_index { |type, index| "#{to_roman_numeral(index + 1, 0, type)}/x" }
      table.headings = ["", *headings]
      table.style = {all_separators: true}

      IONIAN_TYPES.each.with_index do |type, index|
        number_of_accidentals = BORROWED_CHORDS_NUMBER_OF_ACCIDENTALS[index]
        accidentals = accidentals_array_from_number(number_of_accidentals)
        roman_numerals = generate_roman_numerals(IONIAN_TYPES.dup, accidentals, 0, 0, index)

        row_name = "x/#{to_roman_numeral(index + 1, 0, type)}"
        table << [row_name, *roman_numerals]
      end

      return table
    end

    def generate_borrowed_chords_table
      table = Terminal::Table.new
      table.title = "Borrowed Chords"
      table.headings = ["Mode Name", "1", "2", "3", "4", "5", "6", "7"]
      table.style = {all_separators: true}

      roman_numerals = generate_all_roman_numerals
      ACCIDENTAL_ORDER.zip(roman_numerals).each.with_index do |(accidental_order, roman_numerals), index|
        accidental_change = if accidental_order.positive?
                              " (##{accidental_order.abs})"
                            elsif accidental_order.negative?
                              " (b#{accidental_order.abs})"
                            else
                              ""
                            end

        key_name = ACCIDENTAL_ORDER_KEY_NAMES[index]
        raise "Must specify key name" if key_name.nil?
        key_name = key_name + accidental_change

        table << [key_name, *roman_numerals]
      end

      return table
    end

    def accidentals_array_from_number(number_of_accidentals)
      result = LYDIAN_ACCIDENTALS.dup
      accidental_index = ACCIDENTAL_ORDER.dup.index(0)

      update_accidentals_times = number_of_accidentals - 1
      return result if update_accidentals_times == 0

      while update_accidentals_times != 0
        if update_accidentals_times.positive?
          accidental_index -= 1
          update_accidentals_times -= 1
        else
          accidental_index += 1
          update_accidentals_times += 1
        end

        update_accidentals_by_degree_change!(result, ACCIDENTAL_ORDER.dup[accidental_index])
      end

      return result
    end

    def generate_all_roman_numerals
      lydian_index = ACCIDENTAL_ORDER.index(0)

      # generate the flattened keys
      types = LYDIAN_TYPES.dup
      accidentals = LYDIAN_ACCIDENTALS.dup
      flattened_result = ACCIDENTAL_ORDER[lydian_index + 1..].map do |degree_change|
        generate_roman_numerals(types, accidentals, degree_change, 4, 0)
      end

      # generate the sharpened keys
      types = LYDIAN_TYPES.dup
      accidentals = LYDIAN_ACCIDENTALS.dup
      sharpened_result = ACCIDENTAL_ORDER[..lydian_index - 1].reverse.map do |degree_change|
        generate_roman_numerals(types, accidentals, degree_change, -4, 0)
      end

      return [
        *sharpened_result.reverse,
        generate_roman_numerals(LYDIAN_TYPES.dup, LYDIAN_ACCIDENTALS.dup, 0, 0, 0),
        *flattened_result,
      ]
    end

    def update_accidentals_by_degree_change!(accidentals, degree_change)
      if degree_change.positive?
        change_accidental_index = degree_change.abs - 1
        accidentals[change_accidental_index] += 1
      elsif degree_change.negative?
        change_accidental_index = degree_change.abs - 1
        accidentals[change_accidental_index] -= 1
      end
    end

    def generate_roman_numerals(types, accidentals, degree_change, types_rotation, numbers_rotation)
      types.rotate!(types_rotation)

      update_accidentals_by_degree_change!(accidentals, degree_change)

      numbers = (1..7).to_a.rotate(numbers_rotation)
      accidentals = accidentals.rotate(numbers_rotation)
      roman_numerals = numbers.map.with_index do |number, index|
        to_roman_numeral(number, accidentals[index], types[index])
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
