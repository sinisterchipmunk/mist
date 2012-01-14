Feature: Create new post
  As a blog owner
  In order to add content and attract users to my blog
  I want to create a post
  
  Scenario: Create new post from index
    Given I am on the posts page
    When I follow "New Post"
      And I fill in "Title" with "Post title"
      And I fill in "Content" with "This is post content"
      And I press "Save"
    Then I should be on the posts page
      And I should see "Post title"
