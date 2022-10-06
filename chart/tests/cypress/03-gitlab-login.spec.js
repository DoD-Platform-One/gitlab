Cypress.on('uncaught:exception', (err, runnable) => {
  // returning false here prevents Cypress from
  // failing the test
  if (err.message.includes('Cannot read properties of null')) {
    return false
  }  
})

describe('Gitlab Login', () => {
  it('Check admin is able to login', () => {
    // test login
    cy.visit('/users/sign_in')
    cy.get('input[id="user_login"]').type('root')
    cy.get('input[id="user_password"]').type(Cypress.env('adminpassword'))
    cy.get('button[type="submit"][name="button"]').click()

    // approve new user
    cy.visit('/admin/users')
    cy.get('a[data-qa-selector="pending_approval_tab"]').click()

    cy.get('body').then($body => {
      if ($body.find('button[id="__BVID__65__BV_toggle_"]').length > 0 ) {
        // version 14.8.2
        // cy.get('button[id="__BVID__35__BV_toggle_"]').click()
        // cy.get('button[data-qa-selector="approve_user_button"]').click()
        // cy.get('button[data-qa-selector="approve_user_confirm_button"]').click()

        // version 14.9.2
        cy.get('button[id="__BVID__65__BV_toggle_"]').click()
        cy.get('button[data-qa-selector="approve_user_button"]').click()
        cy.get('button[data-qa-selector="approve_user_confirm_button"]').click()
      }
    })
  })
})
