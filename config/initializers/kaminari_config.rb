# frozen_string_literal: true

Kaminari.configure do |config|
  # Default number of items per page
  config.default_per_page = 10
  
  # Maximum number of items per page (for security)
  config.max_per_page = 100
  
  # Number of page links to show
  config.window = 4
  
  # Number of outer window links to show
  config.outer_window = 0
  
  # When to show left/right buttons
  config.left = 0
  config.right = 0
  
  # Page parameter name
  config.param_name = :page
  
  # Enable total count
  # Setting this to false can improve performance for large datasets
  # config.count_pages = true
end
