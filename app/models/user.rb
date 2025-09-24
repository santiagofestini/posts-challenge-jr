# == Schema Information
#
# Table name: users
#
#  id         :bigint           not null, primary key
#  login      :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_users_on_login  (login) UNIQUE
#
class User < ApplicationRecord
  validates :login, presence: true, uniqueness: true

  has_many :posts, dependent: :destroy
  has_many :ratings, dependent: :destroy
end
