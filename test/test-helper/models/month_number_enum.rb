module TestComponent
  # An enum representing the months of a year
  class MonthNumberEnum
    MONTH_NUMBER_ENUM = [
      # description for JANUARY
      JANUARY = 1,

      # description for FEBRUARY
      FEBRUARY = 2,

      # description for MARCH
      MARCH = 3,

      # description for APRIL
      APRIL = 4,

      # description for MAY
      MAY = 5,

      # description for JUNE
      JUNE = 6,

      # description for JULY
      JULY = 7,

      # description for AUGUST
      AUGUST = 8,

      # description for SEPTEMBER
      SEPTEMBER = 9,

      # description for OCTOBER
      OCTOBER = 10,

      # description for NOVEMBER
      NOVEMBER = 11,

      # description for DECEMBER
      DECEMBER = 12
    ].freeze

    def self.validate(value)
      return false if value.nil?

      MONTH_NUMBER_ENUM.include?(value)
    end
  end
end
