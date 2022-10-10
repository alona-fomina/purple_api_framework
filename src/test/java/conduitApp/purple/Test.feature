
@r
Feature: Vali

  Background:
    * def token = "eyJraWQiOiJ1cy13ZXN0LTIxIiwidHlwIjoiSldTIiwiYWxnIjoiUlM1MTIifQ.eyJzdWIiOiJ1cy13ZXN0LTI6YzE1ZmZlZmUtNDAwZS00MWVmLWIzZTAtM2FkYTk3Y2RhM2FiIiwiYXVkIjoidXMtd2VzdC0yOmEyZjllZTBlLWU5MTMtNGM2ZC1hYjljLTM5NGMyZDFkMjU1ZCIsImFtciI6WyJ1bmF1dGhlbnRpY2F0ZWQiXSwiaXNzIjoiaHR0cHM6Ly9jb2duaXRvLWlkZW50aXR5LmFtYXpvbmF3cy5jb20iLCJodHRwczovL2NvZ25pdG8taWRlbnRpdHkuYW1hem9uYXdzLmNvbS9pZGVudGl0eS1wb29sLWFybiI6ImFybjphd3M6Y29nbml0by1pZGVudGl0eTp1cy13ZXN0LTI6NDI4MDI4MjM5NDE0OmlkZW50aXR5cG9vbC91cy13ZXN0LTI6YTJmOWVlMGUtZTkxMy00YzZkLWFiOWMtMzk0YzJkMWQyNTVkIiwiZXhwIjoxNjY1NDM4NTcyLCJpYXQiOjE2NjU0Mzc5NzJ9.L1O4IkkA09jHFEdG6Il_TUQQ9ihJYrdnBqmATlJPGPvuooilrHx5j0dAFhxpdFttsXetzY4pPzTpmDnoV1EcIIyvD5qaZ-_ypgn0EZzvn8Ov7ghwI4Mken6kqLtawLZtkdDqtJcSWtvODDYd5dR86IZwXPjxRvdN_nVeUJUpm6DM8scd_-OAHOp659SkAKGYST4F-C43cl35W9Ir5ctAa7EaluWB7oFwdt2Rabak7LfkPVf3bOg1XAKhciIqvNJaSgWGI1T5zyaVQ3oWvjTxtygPamyR1NBHH449twJQM85WZICalqsRjvE6qMlL8fZFOlR3hRHL9V_KhKHbU5cv2Q"
    * url 'https://commerce-api-stage.purple.com/carts'


  Scenario: Get Active Cart
    Given path '/active-cart/'
    And header Authorization = 'Bearer ' + token
    When method Get
    Then status 200
    And match response ==
            """
            {
            id: #string,
            customerId: #ignore,
            customerEmail: #string,
            anonymousId: #string,
            shippingAddress: #ignore,
            customLineItems: #array,
            discountCodes: #array,
            totalPrice: {
                type: #string,
                currencyCode: #string,
                centAmount: #number,
                fractionDigits: #number
            },
            taxedPrice: #ignore,
            lineItems: #array,
            giftCards: #array,
            versionModifiedAt: #string,
            shippingMode: #string,
            shipping: #array,
            directDiscounts: #array,
            totalLineItemQuantity: #ignore,
            source: #string
            }
            """
    Given path '/line-items'
    And request [{"sku": "10-38-13050","quantitiy": 1}]
    And header Authorization = 'Bearer '+ token
    When method Post
    Then status 200
    * def line_itemid = response.lineItems[0].id

    Given path '/shipping-methods'
    And header Authorization = 'Bearer '+ token
    When method Get
    Then status 200

    Given path '/shipping-address'
    And request {"firstName":"Knopa","lastName":"Fomina","streetAddress":"352 Pembroke Court","postalCode":"60193","city":"Chicago","state":"IL","country":"US","email":"vitalik.fomin@gmail.com","apartment":"8"}
    And header Authorization = 'Bearer '+ token
    When method Post
    Then status 200
    And match response ==
    """
    {
    id: #string,
    customerEmail: #string,
    anonymousId: #string,
    customLineItems: #array,
    shippingAddress:
    {
        firstName: #string,
        lastName: #string,
        streetName: #string,
        postalCode: #string,
        city: #String,
        state: #string,
        country: #string,
        email: #string
    },
    discountCodes: #array,
    totalPrice: {
        type: #string,
        currencyCode: #srting,
        centAmount: #number,
        fractionDigits: #number
    },
    lineItems: #array,
    giftCards: #array,
    versionModifiedAt: #string,
    shippingMode: #string,
    shipping: #array,
    directDiscounts: #array,
    source: #string
}
    """
    Given path '/line-items/' + line_itemid
    And header Authorization = 'Bearer '+ token
    When method Delete
    Then status 200
#Feature: Test
#
#  Background:
#    * def token = "eyJraWQiOiJ1cy13ZXN0LTIxIiwidHlwIjoiSldTIiwiYWxnIjoiUlM1MTIifQ.eyJzdWIiOiJ1cy13ZXN0LTI6YzE1ZmZlZmUtNDAwZS00MWVmLWIzZTAtM2FkYTk3Y2RhM2FiIiwiYXVkIjoidXMtd2VzdC0yOmEyZjllZTBlLWU5MTMtNGM2ZC1hYjljLTM5NGMyZDFkMjU1ZCIsImFtciI6WyJ1bmF1dGhlbnRpY2F0ZWQiXSwiaXNzIjoiaHR0cHM6Ly9jb2duaXRvLWlkZW50aXR5LmFtYXpvbmF3cy5jb20iLCJodHRwczovL2NvZ25pdG8taWRlbnRpdHkuYW1hem9uYXdzLmNvbS9pZGVudGl0eS1wb29sLWFybiI6ImFybjphd3M6Y29nbml0by1pZGVudGl0eTp1cy13ZXN0LTI6NDI4MDI4MjM5NDE0OmlkZW50aXR5cG9vbC91cy13ZXN0LTI6YTJmOWVlMGUtZTkxMy00YzZkLWFiOWMtMzk0YzJkMWQyNTVkIiwiZXhwIjoxNjY1NDM0MzM0LCJpYXQiOjE2NjU0MzM3MzR9.TNsE9illfgLuJFa4A2SchBkRk047Rt99wPljU9H0uhHbfvx9GLDkOT3Fg_XQr9TJh3s4i2m9kUj0MJLiLZwaudkHKhOAWm6zrZhb2kMUL9tWIsexBOSIWeCfoK4jvZ-qznepgRP6Lw6VrOQ8gOXIPDUonpOBDpOd4G7QTUiMDgykZMcHSDsMO98LI1ZiQUycsJzl9_IQf2hoyBFtwf9uzO3uuO03G40ci72Ni6xdIby0cb58RnReM1LNgpqQMC8W85Q7c6bGMBifMBXvmSvRLBWgsHCo0NQo_AbnzbbLMQp91oCBhPYrpM7BrKz3ZeLGWK_ktRNws7fYz1r2-6--pw"
#    * url 'https://commerce-api-stage.purple.com/carts'
#
#  Scenario: Gets the available shipping methods for the active cart
#    Given path '/active-cart/'
#    And request [{"sku": "10-38-13050","quantitiy": 1}]
#    And header Authorization = 'Bearer '+ token
#    When method Post
#    Then status 200
#    * def line_itemid = response.lineItems[0].id
#
#    Given path '/shipping-methods'
#    When method Get
#    Then status 200
#    And match response ==
#"""
#  {
#  key: #string,
#  name: #string,
#  groups: #array
#  }
#  """
#    Given path '/line-items/' + line_itemid
#    And header Authorization = 'Bearer '+ token
#    When method Delete
#    Then status 200