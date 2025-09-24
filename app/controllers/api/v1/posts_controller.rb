class Api::V1::PostsController < ApplicationController
  def create
    user = User.find_or_create_by!(login: post_params[:user_login])
    post = Post.create!(title: post_params[:title], body: post_params[:body], ip: post_params[:user_ip], user:)

    render json: {
      post: post.as_json(except: [ :created_at, :updated_at ]).merge(
        user: user.as_json(
          only: [ :id, :login ])
      )
    }, status: :created
  end

  def top
    posts = Post.top_by_rating(params[:limit])

    render json: {
      posts: posts.map { |post| post.as_json(only: [ :id, :title, :body ]) }
    }
  end

  def shared_ips
    results = Post.with_shared_ips

    render json: results.map { |r| { ip: r.ip, author_logins: r.author_logins } }
  end

  private

  def post_params
    params.permit(:title, :body, :user_login, :user_ip)
  end
end
