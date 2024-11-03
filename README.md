# README

## Little Shop Project - Backend
Link to [frontend](https://github.com/dcardona23/little-shop-fe-group-starter)

### Contributors
* [Bryan Willet](https://github.com/bwillett2003)
* [Danielle Cardona](https://github.com/dcardona23)
* [Jeremiah Ross](https://github.com/Crosswolfv1)
* [Michael OBrien](https://github.com/MiTOBrien)

**Ruby version:** 3.2.2

**Rails version:** 7.1.4.2

**System dependencies/gems:**
- postgresql version 14.13
- jsonapi-serializer
- simplecov
- rspec-rails
- should-matchers
- pry
- faker

**Configuration**
#### Database creation
- from the main project directory run: rails db:{drop,create,migrate,seed}

### Database initialization
- from the main project direcotry run: rails db:schema:dump

### How to run the test suite
- from the main project directory run: 'bundle exec rspec spec

### Services (job queues, cache servers, search engines, etc.)

### Deployment instructions
- Clone project down to your computer
- cd into the project directory
- run 'bundle install'
- run rails d:{drop,create,migrate,seed}
- run rails db:schema:dump
