# frozen_string_literal: true

# Commodity time formatting functions
module TimeExtensions
  refine Time do
    # Format a date in our specific format
    # @example Format a date
    #   format_short_date(Time.new(2002)) #=> 'January  1, 2002'
    def short_date
      self.strftime '%B %e, %Y'
    end

    # Format a date in our specific format
    # @example Format a date
    #   Time.new(2002).format_date #=> 'January  1, 2002, 12:00 AM'
    def standard_format
      self.strftime '%B %e, %Y, %l:%M %p'
    end
  end
end