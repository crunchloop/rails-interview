module ExternalApi
  class Client
    BASE_URL = ENV.fetch("EXTERNAL_API_BASE_URL", "http://localhost:3001")

    class ApiError < StandardError
      attr_reader :status, :body

      def initialize(status, body)
        @status = status
        @body = body
        super("External API error — status: #{status}, body: #{body}")
      end
    end

    class NotFoundError < ApiError; end
    class UnprocessableError < ApiError; end

    def self.instance
      @instance ||= new
    end

    def get(path)
      response = connection.get(path)
      handle_response(response)
    end

    def post(path, body)
      response = connection.post(path, body.to_json)
      handle_response(response)
    end

    def patch(path, body)
      response = connection.patch(path, body.to_json)
      handle_response(response)
    end

    def delete(path)
      response = connection.delete(path)
      handle_response(response)
    end

    private

    def connection
      @connection ||= Faraday.new(url: BASE_URL) do |f|
        f.request :json
        f.response :json
        f.response :logger, Rails.logger, headers: false, bodies: false do |logger|
          logger.filter(/(Authorization:)(.+)/, '\1 [FILTERED]')
        end
        f.adapter Faraday.default_adapter
      end
    end

    def handle_response(response)
      case response.status
      when 200..299
        response.body
      when 404
        raise NotFoundError.new(response.status, response.body)
      when 422
        raise UnprocessableError.new(response.status, response.body)
      else
        raise ApiError.new(response.status, response.body)
      end
    end
  end
end
