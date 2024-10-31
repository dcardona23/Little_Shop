class ErrorSerializer
  def self.format_error(exception, status)
    {
      message: "Your query could not be completed",
      errors: format_errors(exception, status)
    }
  end

  private

  def self.format_errors(exception, status)
    if exception.is_a?(ActiveRecord::RecordInvalid) || exception.is_a?(ActionController::ParameterMissing)
      Array(exception.is_a?(ActiveRecord::RecordInvalid) ? exception.record.errors.full_messages : exception.message)
    else
      [
        {
          status: status.to_s,
          title: exception.message
        }
      ]
    end
  end
end
