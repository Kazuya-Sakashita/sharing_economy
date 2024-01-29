class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable

  validates :nickname, presence: true
  validates :gender, presence: true
  before_validation :skip_confirmation!, if: :new_record?

  has_one :user_information, dependent: :destroy
  has_one :user_mobile_phone, dependent: :destroy

  enum gender: {
    unanswered: 0,
    male: 1,
    female: 2
  }

  class << self
    def genders_i18n
      I18n.t("enums.user.gender")
    end
  end

  def remember_me
    true
  end
end
