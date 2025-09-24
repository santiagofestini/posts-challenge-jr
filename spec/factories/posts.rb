FactoryBot.define do
  factory :post do
    user
    title { "Sample Post Title" }
    body { "This is a sample post body with some content." }
    ip { "192.168.1.1" }
    ratings_sum { 0 }
    ratings_count { 0 }
  end
end
