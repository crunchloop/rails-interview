# frozen_string_literal: true

module Api
  class BaseController < ApplicationController
    before_action :check_format

    skip_before_action :verify_authenticity_token

    private

    def check_format
      return if request.format.json?

      raise ActionController::RoutingError, 'Not supported format'
    end
  end
end
