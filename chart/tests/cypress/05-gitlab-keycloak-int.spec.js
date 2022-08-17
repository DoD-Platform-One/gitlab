// This will find the oauth button in an app's login page, click it, add the 
// consent between the user and app, then listen for HTTP statuses to make sure
// keycloak redirects back to the app and that the app loads properly.
// the username and password are defined in enivronment variables:
//
// cypress_keycloak_username
// cypress_keycloak_password

if (Cypress.env('keycloak_test_enable')) {

  Cypress.on('uncaught:exception', (err, runnable) => {
      return false
    })

  describe('Login with Keycloak', () => {
    it('Ensure a user can log in via keycloak sso', () => {
      cy.visit('/users/sign_in')
      cy.get('button[id="oauth-login-openid_connect"]').click()
      cy.get('input[id="username"]').type(Cypress.env('keycloak_username'))
      cy.get('input[id="password"]').type(Cypress.env('keycloak_password'))
      cy.get('input[id="kc-login"]').click()
      cy.get('input[id="kc-accept"]').click()
      cy.intercept('GET', '**/*').as('landingpage')
      cy.get('input[id="kc-login"]').click()
      // after hitting "yes" on the consent page, there should be a redirect back to the app (302)
      cy.wait('@landingpage').its('response.statusCode').should('eq', 302)
      // then the app's page should load
      cy.wait('@landingpage').its('response.statusCode').should('eq', 200)
    })
  })
}
