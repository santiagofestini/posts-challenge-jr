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

  def self.top_by_rating(limit)
    where("ratings_count > 0")
      .select("posts.*, CASE WHEN ratings_count > 0 THEN ratings_sum::decimal / ratings_count ELSE 0 END as calculated_avg")
      .order("calculated_avg DESC")
      .limit(limit)
  end

  def self.with_shared_ips
    Post
      .joins(:user)
      .select("posts.ip, ARRAY_AGG(DISTINCT users.login) AS author_logins")
      .group("posts.ip")
      .having("COUNT(DISTINCT posts.user_id) >= 2")
  end
end
