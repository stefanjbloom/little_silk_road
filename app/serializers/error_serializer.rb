class ErrorSerializer
  def self.format_error(exception, status)
    {
      message: 'We could not complete your request, please enter new query.',
      errors: [exception.message]
    }
  end
end