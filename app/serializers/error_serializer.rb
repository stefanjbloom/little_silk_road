class ErrorSerializer
  def self.format_error(exception, status)
    {
      message: 'We could not complete your request, please enter new query.',
      errors: [exception.message]
    }
  end
end

# NOTE: For when we reference this project in the future.

# below is properly the formatted error response for JSON convention.
# error should be the only top level key.

# class ErrorSerializer
#   def self.format_error(exception, status)
#     {
#       errors: [
#         {
#           status: status,
#           title: exception.message
#         }
#       ]
#     }
#   end
# end