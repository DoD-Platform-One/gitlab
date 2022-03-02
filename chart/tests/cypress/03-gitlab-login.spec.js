
describe('Gitlab Login', () => {
  it('Check admin is able to login', () => {
    // test login
    cy.visit('/users/sign_in')
    cy.get('input[id="user_login"]').type('root')
    cy.get('input[id="user_password"]').type(Cypress.env('adminpassword'))
    cy.get('input[type="submit"]').click()

    // approve new user
    cy.visit('/admin/users')
    cy.get('a[data-qa-selector="pending_approval_tab"]').click()

    cy.get('body').then($body => {
      if ($body.find('button[id="__BVID__35__BV_toggle_"]').length > 0 ) {
        // version 14.1.x 14.2.x 14.3.x
        // cy.get('button[id="__BVID__32__BV_toggle_"]').click()
        // cy.get('button[data-path="/admin/users/'+Cypress.env('gitlab_username')+'/approve"]').click()
        // cy.get('button[data-qa-selector="approve_user_confirm_button"]').click()

        // version 14.6.0
        // cy.get('button[id="__BVID__33__BV_toggle_"]').click()
        // cy.get('button[data-qa-selector="approve_user_button"]').click()
        // cy.get('button[data-qa-selector="approve_user_confirm_button"]').click()

        // version 14.8.2
        cy.get('button[id="__BVID__35__BV_toggle_"]').click()
        cy.get('button[data-qa-selector="approve_user_button"]').click()
        cy.get('button[data-qa-selector="approve_user_confirm_button"]').click()
      }
    })
  })
})
