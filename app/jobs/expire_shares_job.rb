class ExpireSharesJob < ApplicationJob
  queue_as :default

  def perform
    expired_shares = Share.where("expires_at < ?", Time.current)
    count = expired_shares.count
    expired_shares.destroy_all
    Rails.logger.info "Deleted #{count} expired shares"
  end
end
