Feature: Set up Mist
  As a blog maintainer
  In order to have a blog
  I want to initialize the Mist repo
  
  Scenario: Generate default mist repo
    Given there is no mist repo
    When I run "rails g mist:setup"
    Then there should be a directory called "db/mist.repo"
    