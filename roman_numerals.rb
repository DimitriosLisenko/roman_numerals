class RomanNumerals
  def output_roman_numerals
    roman_numerals = generate_all_roman_numerals
  end

  private

  TYPE_MAJOR = "major"
  TYPE_MINOR = "minor"
  TYPE_DIMINISHED = "diminished"
  TYPES = [TYPE_MAJOR, TYPE_MINOR, TYPE_DIMINISHED]
  LYDIAN_TYPES = [TYPE_MAJOR, TYPE_MAJOR, TYPE_MINOR, TYPE_DIMINISHED, TYPE_MAJOR, TYPE_MINOR, TYPE_MINOR]
  LYDIAN_ACCIDENTALS = [0, 0, 0, 1, 0, 0, 0]

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
  ]

  private_constant :TYPE_MAJOR
  private_constant :TYPE_MINOR
  private_constant :TYPE_DIMINISHED
  private_constant :TYPES
  private_constant :LYDIAN_TYPES
  private_constant :ACCIDENTAL_ORDER

  class << self
    def generate_all_roman_numerals
      lydian_index = ACCIDENTAL_ORDER.index(0)

      # generate the flattened keys
      types = LYDIAN_TYPES.clone
      accidentals = LYDIAN_ACCIDENTALS.clone
      flattened_result = ACCIDENTAL_ORDER[lydian_index + 1..].map do |degree_change|
        generate_roman_numerals(types, accidentals, degree_change, 4)
      end

      # generate the sharpened keys
      types = LYDIAN_TYPES.clone
      accidentals = LYDIAN_ACCIDENTALS.clone
      sharpened_result = ACCIDENTAL_ORDER[..lydian_index - 1].reverse.map do |degree_change|
        generate_roman_numerals(types, accidentals, degree_change, -4)
      end

      return [
        *sharpened_result.reverse,
        generate_roman_numerals(LYDIAN_TYPES.clone, LYDIAN_ACCIDENTALS.clone, 0, 0),
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
