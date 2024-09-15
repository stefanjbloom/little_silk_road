class ErrorSerializer
  # include JSONAPI::Serializer
  def self.format_error(exception, status)
    {
      errors: [
        {
          status: status,
          title: exception.message
        }
      ]
    }
  end
end