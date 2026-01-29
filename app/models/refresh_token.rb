require 'securerandom'

class RefreshToken < ApplicationRecord
  belongs_to :user
  before_create :set_token_and_expiry

  scope :active, -> { where(revoked: false).where('expires_at > ?', Time.current) }

  def revoke!
    update!(revoked: true)
  end

  private

  def set_token_and_expiry
    self.token ||= SecureRandom.hex(64)
    self.expires_at ||= 30.days.from_now
  end
end
