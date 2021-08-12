describe('Gitlab Login', () => {
  it('Check admin is able to login', () => {
    // test login
    cy.visit('/users/sign_in')
    cy.get('input[id="user_login"]').type('root')
    cy.get('input[id="user_password"]').type(Cypress.env('adminpassword'))
    cy.get('input[type="submit"]').click()

    // approve new user
    cy.visit('/admin/users')
    // cy.get('a[href="/admin/application_settings/general#js-signup-settings"]').click()
    // cy.get('li.home a[href="/admin"]').first().click()
    // cy.get('a[title="Users"]').click()
    cy.get('a[data-qa-selector="pending_approval_tab"]').click()
    cy.get('button[id="__BVID__30__BV_toggle_"]').click()
    cy.get('a[href="/admin/users/testuser/approve"]').click()
  })
})
