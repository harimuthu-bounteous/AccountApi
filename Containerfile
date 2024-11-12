# Use an official Ruby runtime as a parent image
FROM ruby:3.3.5-alpine

# Set the working directory in the container
WORKDIR /app

# Install dependencies
RUN apk add --no-cache build-base postgresql-dev

# Install Rails
RUN gem install rails

# Set up the application
COPY . .

# Install gems
RUN bundle install

# Expose port 3000 for Rails
EXPOSE 3000

# Command to run the app
CMD ["bin/rails", "server", "-b", "0.0.0.0"]
