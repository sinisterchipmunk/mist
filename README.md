# Mist

A Git-powered, Gist-backed blogging engine for Rack / Ruby on Rails applications.

## Quickest Possible Usage

To go from zero to running as quickly as humanly possible, follow these steps:

  1. Generate rails project:
         $ rails g my_project
  2. Add `mist` gem and install bundle:
         $ echo "gem 'mist', :git => 'http://github.com/sinisterchipmunk/mist'" >>Gemfile
         $ bundle install
  3. Run the Mist installer:
         $ rails g mist:setup
  4. Visit http://localhost:3000/posts and enjoy!
  
## Authorization

Mist doesn't automate authorization. Since it's designed to be dropped into an already-existing Rails application, it is assumed that you have already settled on an authentication / authorization scheme.

Mist provies the `authorize` hook to allow you to run code when needed, returning a true or false value to indicate the user is or isn't authorized, respectively. If true, the user will be allowed to create new posts, edit existing ones, and delete them.

Here's an example of setting up basic authentication using Mist, assuming the logged-in user is in a controller method called `current_user`:

    Mist.authorize do |controller|
      # Authorize only if the user is logged in and is an admin
      controller.current_user and controller.current_user.admin?
    end

See the documentation for Mist::Configuration for much more detailed information about how to authorize users.

## Views

When you run the `mist:setup` generator, Mist places its views into your app (`app/views/mist`, `app/assets/javascripts/mist`, `app/assets/stylesheets/mist`, etc.). You should seriously consider modifying these views, if only so you have a personalized site layout.

## Tweaking

You can configure Mist with an initializer. Just create a file in `config/initializers/mist.rb`. The configuration options you should think about right away are:

    Mist.title = "Blog Title"
      # The title of the blog
      
    Mist.author.name = "Blog Owner's Name"
      # The real (or false?) name of the blog owner, as visitors should see it
    Mist.author.email = "Blog Owner's Email"
      # A contact email address for the blog owner
      
    ActiveGist::API.username = "Blog Owner's GitHub Username"
    ActiveGist::API.password = "Blog Owner's GitHub Password"
      # GitHub credentials aren't really required, but Gists will be posted
      # anonymously and can't be edited unless credentials are given.

## Under the Hood

The rest of this README is dedicated to digging deeper into how Mist works, so that you too can feel the full power of Git-backed blogging!

### Post Format

Mist posts use Markdown format. There's not much more to say about that, except concerning code examples.

Let's take the following example post:

    # Here is a header
    
    Here is a paragraph of post content
    
        def code_example_start
          @code_counter += 1
        end
    
The above example will be rendered using normal Markdown until the code example is encountered. At this point, mist will extract the code from the example, and send it off into a Gist. If there are multiple code examples, each code example is treated as a separate file within the same Gist.

When the blog is rendered as HTML, the Gist is embedded directly into it.

Gists are great because they allow other people to fork your code examples, recommend changes, comment on them, and so on. But they suddenly become really powerful if you adopt the convention of naming your code examples. Let's take the same example, with this change:

  # Here is a header

  Here is a paragraph of post content

      file: code_snippet.rb
      def code_example_start
        @code_counter += 1
      end
    
Note the `file: ...` line. If Mist finds this line at the top of your code example, it will extract the filename and send it as the name of the example's particular file within the Gist. Then, GitHub will auto-detect the example's format from the file extension, and do all the syntax highlighting of your code when it is embedded!

If the Gist cannot be found (GitHub is down or the Gist has been deleted), Mist will fall back to regular Markdown formatting for the code example. You'll lose syntax highlighting, but the code itself will still be formatted properly.


### The Mist Repository

By default, Mist keeps its git repository at `db/mist.repo.#{Rails.env}`. You can configure this by setting `Mist.repository_location` in `config/initializers/mist.rb` if you want.

If the repository doesn't exist the first time Mist tries to read from or write to it, Mist will create a new git repository out of thin air. Mist doesn't set up any remotes or whatever; it just build a bare-bones git repo so that it has something to commit to.

Because it's Git, you can jump into it and add remotes, create branches and check out, add tags -- and do pretty much whatever you like with it.

By default, when you save a blog post, Mist won't push the repository to remote. If you'd like to change this, set the configuration option `Mist.push_posts = true`.
