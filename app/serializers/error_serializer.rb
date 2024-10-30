class ErrorSerializer
  def self.format_error(exception, status)
    {
      errors: [
        {
          status: status.status_code,
          title: exception.message
        }
      ]
    }
  end
end