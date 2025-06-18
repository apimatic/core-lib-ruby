module TestComponent
  # An enum representing the months of a year
  class MonthNameEnum
    MONTH_NAME_ENUM = [
      # description for JANUARY
      JANUARY = 'January'.freeze,

      # description for FEBRUARY
      FEBRUARY = 'February'.freeze,

      # description for MARCH
      MARCH = 'March'.freeze,

      # description for APRIL
      APRIL = 'April'.freeze,

      # description for MAY
      MAY = 'May'.freeze,

      # description for JUNE
      JUNE = 'June'.freeze,

      # description for JULY
      JULY = 'July'.freeze,

      # description for AUGUST
      AUGUST = 'August'.freeze,

      # description for SEPTEMBER
      SEPTEMBER = 'September'.freeze,

      # description for OCTOBER
      OCTOBER = 'October'.freeze,

      # description for NOVEMBER
      NOVEMBER = 'November'.freeze,

      # description for DECEMBER
      DECEMBER = 'December'.freeze
    ].freeze

    def validate(value)
      return false if value.nil?

      MONTH_NAME_ENUM.include?(value)
    end
  end
end
