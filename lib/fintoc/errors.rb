require 'fintoc/constants'

module Fintoc
  # Fintocs custom errors
  class FintocError < StandardError
    def initialize(error)
      @message = error[:message]
      @doc_url = error[:doc_url] or Fintoc::Constants::GENERAL_DOC_URL
    end

    def message
      "\n#{@message}\n Please check the docs at: #{@doc_url}"
    end

    def to_s
      "\n#{@message}\n Please check the docs at: #{@doc_url}"
    end
  end
  class InvalidRequestError < FintocError; end
  class LinkError < FintocError; end
  class AuthenticationError < FintocError; end
  class InstitutionError < FintocError; end
  class ApiError < FintocError; end
  class MissingResourceError < FintocError; end
  class InvalidLinkTokenError < FintocError; end
  class InvalidUsernameError < FintocError; end
  class InvalidHolderTypeError < FintocError; end
  class MissingParameterError < FintocError; end
  class EmptyStringError < FintocError; end
  class UnrecognizedRequestError < FintocError; end
  class InvalidDateError < FintocError; end
  class InvalidCredentialsError < FintocError; end
  class LockedCredentialsError < FintocError; end
  class InvalidApiKeyError < FintocError; end
  class UnavailableInstitutionError < FintocError; end
  class InternalServerError < FintocError; end
end
