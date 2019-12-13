# frozen_string_literal: true

# Commodity time formatting functions
module TimeExtensions
  refine Time do
    # Format a date in our specific format
    # @example Format a date
    #   Time.new(2002).short_date #=> 'January  1, 2002'
    def short_date
      strftime '%B %e, %Y'
    end

    # Format a date in our specific format
    # @example Format a date
    #   Time.new(2002).standard_format #=> 'January  1, 2002, 12:00 AM'
    def standard_format
      strftime '%B %e, %Y, %l:%M %p'
    end
  end
end
