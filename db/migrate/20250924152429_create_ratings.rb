class CreateRatings < ActiveRecord::Migration[8.0]
  def change
    create_table :ratings do |t|
      t.belongs_to :post, null: false, foreign_key: true
      t.belongs_to :user, null: false, foreign_key: true
      t.integer :value, null: false

      t.timestamps
    end

    add_index :ratings, [ :post_id, :user_id ], unique: true
    add_check_constraint :ratings, "value >= 1 AND value <= 5", name: "value_range_check"
  end
end
