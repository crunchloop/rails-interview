# frozen_string_literal: true

class BaseController < ApplicationController
  before_action :check_format

  private

  def check_format
    return if request.format.html? || request.format.turbo_stream?

    raise ActionController::RoutingError, 'Not supported format'
  end
end
