# This hook is called whenever Mist needs to know if a user
# is allowed to do something. You can also pass in specific
# actions such as :create_post, :edit_post and so on. See
# documentation for details.
Mist.authorize :all do |controller|
  true
end


Mist.title = "Blog Title"
Mist.author.name = "John Doe"
Mist.author.email = "john@example.com"

# GitHub credentails -- without these you can't edit Gists
# because they're anonymous
ActiveGist::API.username = ENV['GITHUB_USERNAME']
ActiveGist::API.password = ENV['GITHUB_PASSWORD']
