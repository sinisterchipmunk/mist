Feature: Update existing post
  As a blog owner
  In order to keep content up-to-date so users keep visiting
  I want to update an existing post

  Background:
    Given I have published a post called "Post title"
  
  Scenario: Update existing post from index
    When I edit the "Post title" post
      And I fill in "Title" with "New title"
      And I fill in "Content" with "This is MOAR post content"
      And I press "Save"
    Then I should see "New title"
      And I should see "This is MOAR post content"
    
    When I go to the posts page
    Then I should see "New title"
      And I should not see "Post title"
