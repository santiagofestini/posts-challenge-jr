FactoryBot.define do
  factory :rating do
    post
    user
    value { rand(1..5) }
  end
end
