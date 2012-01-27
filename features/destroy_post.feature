Feature: Destroy existing post
  As a blog owner
  In order to remove old content that is no longer useful
  I want to destroy an existing post

  Background:
    Given I have published a post called "Post title"
      And I am on the posts page
  
  Scenario: Update existing post from index
    When I follow "Destroy"
    Then I should be on the posts page
      And I should not see "Post title"
