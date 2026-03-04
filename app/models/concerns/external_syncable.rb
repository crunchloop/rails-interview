# frozen_string_literal: true

module ExternalSyncable
  extend ActiveSupport::Concern

  included do
    thread_mattr_accessor :skip_sync_callbacks, instance_accessor: false

    after_commit :enqueue_outbound_sync_create, on: :create,  unless: :sync_skipped?
    after_commit :enqueue_outbound_sync_update, on: :update,  unless: :sync_skipped?
    after_commit :enqueue_outbound_sync_destroy, on: :destroy, unless: :sync_skipped?
  end

  class_methods do
    def skip_sync
      previous = skip_sync_callbacks
      self.skip_sync_callbacks = true
      yield
    ensure
      self.skip_sync_callbacks = previous
    end
  end

  private

  def sync_skipped?
    self.class.skip_sync_callbacks
  end

  def enqueue_outbound_sync_create
    outbound_job_class.perform_later(id, :create)
  end

  def enqueue_outbound_sync_update
    outbound_job_class.perform_later(id, :update)
  end

  def enqueue_outbound_sync_destroy
    outbound_job_class.perform_later(id, :destroy, external_id: external_id)
  end

  def outbound_job_class
    "Sync::Outbound#{self.class.name}Job".constantize
  end
end
