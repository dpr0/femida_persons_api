class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :authorizations, dependent: :destroy

  def self.auth_by_token(headers)
    return unless headers['Authorization'].present?

    hash = JsonWebToken.decode(headers['Authorization'].split(' ').last)
    @current_user = User.find(hash[:user_id]) if hash && hash[:user_id]
  end

  def find_for_oauth
    auth = authorizations.where(provider: provider, uid: uid).first
    return auth.user if auth

    authorizations.create(provider: provider, uid: uid)
  end
end
