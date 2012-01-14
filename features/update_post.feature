Feature: Update existing post
  As a blog owner
  In order to keep content up-to-date so users keep visiting
  I want to update an existing post
  
  Scenario: Update existing post from index
    Given I have created a post called "Post title"
    When I edit the "Post title" post
      And I fill in "Content" with "This is MOAR post content"
      And I press "Save"
    Then I should see "Post title"
      And I should see "This is MOAR post content"

  Scenario: Change title of existing post
    Given I have created a post called "Old title"
    When I edit the "Old title" post
      And I fill in "Title" with "New title"
      And I press "Save"
    Then I should see "New title"
    
    When I go to the posts page
    Then I should see "New title"
      And I should not see "Old title"
