Feature: Update existing post
  As a blog owner
  In order to keep content up-to-date so users keep visiting
  I want to update an existing post
  
  Scenario: Update existing post from index
    Given I have created a post called "Post title"
      And I am on the posts page
    When I follow "Post title"
      And I follow "Edit"
      And I fill in "Content" with "This is MOAR post content"
      And I press "Save"
    Then I should see "Post title"
      And I should see "This is MOAR post content"
