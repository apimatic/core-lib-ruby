module TestComponent
  # An enum representing the months of a year
  class MonthNameEnum
    MONTH_NAME_ENUM = [
      # TODO: Write general description for JANUARY
      JANUARY = 'January'.freeze,

      # TODO: Write general description for FEBRUARY
      FEBRUARY = 'February'.freeze,

      # TODO: Write general description for MARCH
      MARCH = 'March'.freeze,

      # TODO: Write general description for APRIL
      APRIL = 'April'.freeze,

      # TODO: Write general description for MAY
      MAY = 'May'.freeze,

      # TODO: Write general description for JUNE
      JUNE = 'June'.freeze,

      # TODO: Write general description for JULY
      JULY = 'July'.freeze,

      # TODO: Write general description for AUGUST
      AUGUST = 'August'.freeze,

      # TODO: Write general description for SEPTEMBER
      SEPTEMBER = 'September'.freeze,

      # TODO: Write general description for OCTOBER
      OCTOBER = 'October'.freeze,

      # TODO: Write general description for NOVEMBER
      NOVEMBER = 'November'.freeze,

      # TODO: Write general description for DECEMBER
      DECEMBER = 'December'.freeze
    ].freeze

    def validate(value)
      return false if value.nil? || value.empty?

      return MONTH_NAME_ENUM.include?(value)
    end
  end
end
