describe('Gitlab Signup', () => {
  it('Check user is able to signup', () => {
    // test signup
    cy.visit('/users/sign_up')
    cy.get('input[id="new_user_first_name"]').type(Cypress.env('gitlab_first_name'))
    cy.get('input[id="new_user_last_name"]').type(Cypress.env('gitlab_last_name'))
    cy.get('input[id="new_user_username"]').type(Cypress.env('gitlab_username'))
    cy.get('input[id="new_user_email"]').type(Cypress.env('gitlab_email'))
    cy.wait(3000) // wait 3 seconds for username check to complete
    cy.get('input[id="new_user_password"]').type(Cypress.env('gitlab_password'))
    cy.get('input[type="submit"]').click()
  })
})