Feature: Create Token

Scenario: Create token
    Given url 'https://conduit.productionready.io'
    Given path '/api/users/login'
    And request {"user": {"email": "purple1@gmail.com", "password": "purple1234"}}
    When method Post
    Then status 200
    * def authToken = response.user.token