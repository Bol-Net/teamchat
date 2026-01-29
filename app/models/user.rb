class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  enum role: { guest: 0, member: 1, admin: 2 }

  # Association for refresh tokens
  has_many :refresh_tokens, dependent: :destroy

  validates :name, presence: true
  # Note: email and password validations are handled by Devise
end
