class AddRatingCountersToPosts < ActiveRecord::Migration[8.0]
  def change
    add_column :posts, :ratings_sum, :integer, default: 0
    add_column :posts, :ratings_count, :integer, default: 0
  end
end
