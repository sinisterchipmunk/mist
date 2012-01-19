Feature: Similar Posts
  As a blog owner
  In order to persuade visitors to stay longer
  I want to show them other posts similar to the current one

  Background:
    Given I have published these posts:
      | title | tags           |
      | one   | t1, t2, t3     |
      | two   | t1, t4         |
      | three | t6, t8         |
      | four  | t1, t2, t5, t7 |
      | five  |                |
      | six   | t3, t4, t5     |
      | seven | t1, t2, t3, t4 |
      
  Scenario: Don't show similar posts on index page, because index is not a post
    When I am on the posts page
    Then I should not see "Similar"
  
  Scenario: Show similar posts in order of relevance
    # "relevance" is here defined as "number of matching tags, descending".
    When I look at the "one" post
    Then I should see "Similar"
      And the "similar posts" sidebar should contain:
        | title |
        | seven |
        | four  |
        | six   |
        | two   |
      And the "similar posts" sidebar should not contain:
        | title |
        | one   |
        | three |
        | five  |

  Scenario: Don't show similar posts sidebar if there are no similar posts
    When I look at the "three" post
    Then I should not see "Similar"
    
  Scenario: Don't show similar posts sidebar if there are no tags
    When I look at the "five" post
    Then I should not see "Similar"
