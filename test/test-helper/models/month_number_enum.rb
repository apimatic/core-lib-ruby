module TestComponent
  # An enum representing the months of a year
  class MonthNumberEnum
    MONTH_NUMBER_ENUM = [
      # TODO: Write general description for JANUARY
      JANUARY = 1,

      # TODO: Write general description for FEBRUARY
      FEBRUARY = 2,

      # TODO: Write general description for MARCH
      MARCH = 3,

      # TODO: Write general description for APRIL
      APRIL = 4,

      # TODO: Write general description for MAY
      MAY = 5,

      # TODO: Write general description for JUNE
      JUNE = 6,

      # TODO: Write general description for JULY
      JULY = 7,

      # TODO: Write general description for AUGUST
      AUGUST = 8,

      # TODO: Write general description for SEPTEMBER
      SEPTEMBER = 9,

      # TODO: Write general description for OCTOBER
      OCTOBER = 10,

      # TODO: Write general description for NOVEMBER
      NOVEMBER = 11,

      # TODO: Write general description for DECEMBER
      DECEMBER = 12
    ].freeze

    def validate(value)
      return false if value.nil? || value.empty?

      return MONTH_NUMBER_ENUM.include?(value)
    end
  end
end
