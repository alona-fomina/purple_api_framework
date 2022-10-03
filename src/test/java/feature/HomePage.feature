@regression
Feature: Test for the HomePage
Background:
    Given url 'https://conduit.productionready.io'
@debug
Scenario: Get all tags
    * path '/api/tags'
    When method Get
    Then status 200
    And match response.tags contains ['welcome', 'implementations']
    And match response.tags !contains 'truck'
    And match response.tags == "#array"
    And match each response.tags == "#string"

@ignore
Scenario: Get 10 articles from the page
    * params {limit:10, offset:0}
    * path '/api/articles'
    When method Get
    Then status 200
    And match response.articles == '#[3]' 
    And match response.articlesCount == 3