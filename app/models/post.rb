# == Schema Information
#
# Table name: posts
#
#  id            :bigint           not null, primary key
#  body          :text             not null
#  ip            :string           not null
#  ratings_count :integer          default(0)
#  ratings_sum   :integer          default(0)
#  title         :string           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  user_id       :bigint           not null
#
# Indexes
#
#  index_posts_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class Post < ApplicationRecord
  belongs_to :user

  validates :title, presence: true
  validates :body, presence: true
  validates :ip, presence: true

  has_many :ratings, dependent: :destroy

  def average_rating
    return 0.0 if ratings_count.zero?

    ratings_sum.to_f / ratings_count
  end
end
