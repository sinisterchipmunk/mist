Feature: Format posts with markdown
  As a blog maintainer
  In order to make pages easier to read
  I want them to be automatically formatted using Markdown
  
  Scenario: format posts
    Given I am on the posts page
    When I follow "New Post"
      And I fill in "Title" with "Post title"
      And I fill in "Content" with "* post text"
      And I press "Save"
    # it's testing content, not code! I swear!
    Then the page source should contain "<li>post text</li>"
