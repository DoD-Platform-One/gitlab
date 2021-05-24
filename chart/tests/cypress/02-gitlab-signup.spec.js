describe('Gitlab Signup', () => {
  it('Check user is able to signup', () => {
    // test signup
    cy.visit('/users/sign_up')
    cy.get('input[id="new_user_first_name"]').type('test')
    cy.get('input[id="new_user_last_name"]').type('user')
    cy.get('input[id="new_user_username"]').type('testuser')
    cy.get('input[id="new_user_email"]').type('testuser@example.com')
    cy.wait(3000) // wait 3 seconds for username check to complete
    cy.get('input[id="new_user_password"]').type('12345678')
    cy.get('input[type="submit"]').click()
  })
})