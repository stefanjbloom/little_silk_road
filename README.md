# Little Silk Road

## Abstract

This API exposes data through a set of endpoints that communicate with a seperate front end application. The API handles CRUD operations and handles one-to-many relationships with SQL and ActiveRecord queries.

## Initialization
1. Navigate to another empty directory
1. Fork and clone [this repository](https://github.com/jchirch/little-silkroad-fe)
1. `cd` into cloned repo
1. Run `npm install`
1. Run `npm run dev` to start developing.
1. Navigate to `http://localhost:5173/` in browser.

## Testing
This application uses an RSpec testing suite.
- For Models run: `bundle exec rspec spec/models`
- For Requests run: `bundle exec rspec spec/requests`

## Contributors:
Bloom, Stefan
  - [Github](https://github.com/stefanjbloom)
  - [LinkedIn](https://www.linkedin.com/in/stefanjbloom/)

Chirchirillo, Joe
  - [Github](https://github.com/jchirch)
  - [LinkedIn](https://www.linkedin.com/in/joechirchirillo/)

Fallenius, Karl
  - [Github](https://github.com/SmilodonP)
  - [LinkedIn](https://www.linkedin.com/in/karlfallenius/)

Messersmith, Renee
  - [Github](https://github.com/reneemes)
  - [LinkedIn](https://www.linkedin.com/in/reneemessersmith/)

## Versions
This API was built with ruby 3.2.2 and Rails 7.1.4.
Testing was built with RSpec 3.13
  - rspec-core 3.13.1
  - rspec-expectations 3.13.3
  - rspec-mocks 3.13.1
  - rspec-rails 7.0.1
  - rspec-support 3.13.1
