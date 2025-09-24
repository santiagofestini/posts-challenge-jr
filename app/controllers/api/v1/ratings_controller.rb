class Api::V1::RatingsController < ApplicationController
  def create
    ActiveRecord::Base.transaction do
      rating = Rating.create!(post_id: params[:post_id], user_id: rating_params[:user_id], value: rating_params[:value])

      Post.where(id: params[:post_id]).update_all(
        "ratings_sum = ratings_sum + #{rating.value}, ratings_count = ratings_count + 1"
      )
    end

    post = Post.find(params[:post_id])

    render json: {
      average_rating: post.average_rating
    }, status: :created
  end

private

  def rating_params
    params.permit(:post_id, :user_id, :value)
  end
end
