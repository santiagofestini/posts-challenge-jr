# == Schema Information
#
# Table name: ratings
#
#  id         :bigint           not null, primary key
#  value      :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  post_id    :bigint           not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_ratings_on_post_id              (post_id)
#  index_ratings_on_post_id_and_user_id  (post_id,user_id) UNIQUE
#  index_ratings_on_user_id              (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (post_id => posts.id)
#  fk_rails_...  (user_id => users.id)
#
class Rating < ApplicationRecord
  belongs_to :post
  belongs_to :user

  validates :value, presence: true, inclusion: { in: 1..5 }
  validates :user_id, uniqueness: { scope: :post_id, message: "can only rate a post once" }
end
