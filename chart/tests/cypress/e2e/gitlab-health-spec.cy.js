Cypress.on('uncaught:exception', (err, runnable) => {
  // returning false here prevents Cypress from failing the test
  // gitlab throws this error in the console which by default fails the cypress test
  return false
}) 

describe('Gitlab Signup', () => {
  it('Check user is able to signup', () => {
    // test signup
    cy.visit('/users/sign_up')

    // /users/sign_up is throwing an uncaught exception - we can continue the test by ignoring this single error
    cy.on('uncaught:exception', (err, runnable) => {
      expect(err.message).to.include('Cannot read')

      return false
    })

    cy.get('input[id="new_user_first_name"]').type(Cypress.env('gitlab_first_name'))
    cy.get('input[id="new_user_last_name"]').type(Cypress.env('gitlab_last_name'))
    cy.get('input[id="new_user_username"]').type(Cypress.env('gitlab_username'))
    cy.get('input[id="new_user_email"]').type(Cypress.env('gitlab_email'))
    cy.wait(3000) // wait 3 seconds for username check to complete
    // add user if not already created
    cy.get('.validation-error').then(($userexist) => {
      if ($userexist.hasClass('hide')) {
        cy.get('input[id="new_user_password"]').type(Cypress.env('gitlab_password'))
        cy.get('button[data-testid="new-user-register-button"]').click()
      }
    })
  })
})


describe('Gitlab Login as Root', () => {
  it('Check admin is able to login', () => {
    // test login
    cy.visit('/users/sign_in')
    cy.get('input[id="user_login"]').type('root')
    cy.get('input[id="user_password"]').type(Cypress.env('adminpassword'))
    //cy.get('button[type="submit"][name="button"]').click()
    cy.get('button[data-qa-selector="sign_in_button"').click()

    // approve new user
    cy.visit('/admin/users')
    cy.get('a[data-testid="pending-approval-tab"]').click()

    cy.get('body').then($body => {
      if ($body.find('div[data-testid="user-actions-dropdown-toggle"] > button').length > 0 ) {
        cy.get('div[data-testid="user-actions-dropdown-toggle"] > button').click()
        cy.get('li[data-testid="approve"] > button').click()
        cy.get('button[data-testid="approve-user-confirm-button"]').click()
      }
    })
  })
})


describe('Create Gitlab Project', () => {
  it('Check if KC SSO or Non-SSO user is able to create a project', () => {
    // test login
    // cy.visit(Cypress.env('url')('/users/sign_in'))
    cy.visit('/users/sign_in')
    if (Cypress.env('keycloak_test_enable')) {
        cy.get('button[id="oauth-login-openid_connect"]').click()
        cy.wait(500)
        cy.get('input[id="username"]')
              .type(Cypress.env('keycloak_username'))
              .should('have.value', Cypress.env('keycloak_username'));

        cy.get('input[id="password"]')
          .type(Cypress.env('keycloak_password'))
          .should('have.value', Cypress.env('keycloak_password'));
              
        cy.get('form').submit(); 

        cy.get('input[id="kc-accept"]').click(); 

        cy.get('input[id="kc-login"]').click(); 
      } else {
    
        cy.get('input[id="user_login"]').type(Cypress.env('gitlab_username'))
        cy.get('input[id="user_password"]').type(Cypress.env('gitlab_password'))
        // Old: cy.get('button[type="submit"][name="button"]').click()
        cy.get('button[data-qa-selector="sign_in_button"').click()
      }
    
    // if first login assign Developer role with the joining_team objective
    cy.url().then(($url) => {
      if ($url.includes('welcome')) {
        cy.get('select#user_role').select('software_developer')
        cy.get('select#user_registration_objective').select('code_storage')
        cy.get('button[type="submit"]').click()
      }
    })
    
    // check if project exists
    cy.get('body').then($body => {
      if ($body.find('.project-row').length === 0) {
            // create a repo based with a container registry
            cy.wait(500)
            cy.visit('/projects/new')
            cy.get('a[href="#blank_project"]').click()
            cy.get('input[id="project_name"]').first().type(Cypress.env('gitlab_project')) // for some reason, there are 2 other hidden elements with the same attributes but we only need the first one
            // For some reason, there are 2 other hidden elements with the same attributes but we only need the first one
            // Also use force: true for the click due to the label is covering the radio button (but can still be clicked) 
            cy.get('input[id="project_visibility_level_20"]').first().click({force: true})  
            //commenting out below because 'initial_with_readme' is checked by default now
            //cy.get('input[id="project_initialize_with_readme"]').click({force: true)
            cy.get('button[type="submit"]').first().click()                        // for some reason, there are 2 other hidden elements with the same attributes but we only need the first one
      }
    })

  })
})