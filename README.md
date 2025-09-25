# Posts Challenge API

A Rails API application for managing posts, users, and ratings with high-performance seeding capabilities.

## Features

- **Posts Management**: Create posts with automatic user creation
- **Rating System**: Rate posts (1-5 stars) with concurrency-safe counters
- **Analytics**: Get top-rated posts and shared IP analysis
- **High-Volume Seeding**: Generate 200K+ posts via API endpoints

## API Endpoints

- `POST /api/1/posts` - Create posts (auto-creates users)
- `POST /api/1/ratings` - Rate posts (one rating per user per post)
- `GET /api/1/posts/top?limit=N` - Get top N posts by average rating
- `GET /api/1/posts/shared_ips` - Get IPs used by multiple authors

## Setup

### Requirements
- Ruby 3.4.6
- PostgreSQL
- Rails 8.0.3

### Installation

1. Clone and install dependencies:
   ```bash
   git clone <repository>
   cd posts-challenge-jr
   bundle install
   ```

2. Setup database:
   ```bash
   rails db:create db:migrate
   ```

3. Start server:
   ```bash
   rails server
   ```

4. Seed data (optional - creates 200K posts):
   ```bash
   rails db:seed
   ```

### Testing
```bash
bundle exec rspec
```

### Linter
```bash
bundle exec rubocop -a
```

### Postman collection
```bash
/posts-challenge.postman_collection.json
```

## Technical Decisions

**Simple JSON Responses**: Uses Rails' built-in `as_json` and direct JSON rendering. While serializers like ActiveModel::Serializers would provide better structure for larger APIs, the simple response formats in this demo don't warrant the additional complexity.

**User Creation Strategy**: Users are created automatically when posts are submitted, even if the post itself has validation errors.

**IP Validation**: No regex validation on IP addresses. Accepts any string format to accommodate various IP types and future extensibility.

**Controller-Based Logic**: Business logic remains in controllers rather than using service objects or interactors. For this demo's straightforward operations and limited reuse, the additional abstraction layers would add overhead without meaningful benefits.

**Model Query Methods**: Database query logic is implemented directly in models rather than repository patterns. While repositories would provide better separation of concerns in larger applications, the current query complexity is manageable within ActiveRecord models.

## Architecture

- **Models**: User, Post, Rating with appropriate associations and validations
- **Controllers**: API-only controllers with JSON responses
- **Database**: PostgreSQL with optimized indexes and counter caching
- **Testing**: RSpec with FactoryBot for comprehensive coverage
- **Seeding**: Curl-based API seeding for realistic load testing