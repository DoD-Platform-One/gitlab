// Overrides from gluon commands.js
Cypress.Commands.add('deleteGitlabProject', (url, username, projectName) => {
  cy.visit(`${url}/${username}/${projectName}/edit`)
  cy.get('section[data-testid="advanced-settings-content"]').click()
  cy.get('button[data-testid="delete-button"]').click()
  cy.get('input[data-testid="confirm-name-field"]').type(`${username}/${projectName}`)
  cy.get('button[data-testid="confirm-delete-button"]').click()
})

Cypress.on('uncaught:exception', (err, runnable) => {
  // returning false here prevents Cypress from failing the test
  // gitlab throws this error in the console which by default fails the cypress test
  return false
})


describe('Gitlab Signup', () => {
  it('Check user is able to signup', () => {
    // test signup
    cy.visit(`${Cypress.env('url')}/users/sign_up`)

    cy.get('input[id="new_user_first_name"]').type(Cypress.env('gitlab_first_name'))
    cy.get('input[id="new_user_last_name"]').type(Cypress.env('gitlab_last_name'))

    //Listen for API call to validate username does not exist
    //cy.intercept('GET', '**/exists').as('userExistsCall')
    cy.get('input[id="new_user_username"]').type(Cypress.env('gitlab_username'))
    //cy.wait('@userExistsCall').then(({ response }) => {
    //  expect(response.body).to.deep.equal({ exists: false });
    //})

    cy.get('input[id="new_user_email"]').type(Cypress.env('gitlab_email'))

    cy.wait(3000) // wait 3 seconds for username check to complete
    // add user if not already created
    cy.get('.validation-error').then(($userexist) => {
      if ($userexist.hasClass('hide')) {
        cy.get('input[id="new_user_password"]').type(Cypress.env('gitlab_password'))
        cy.get('button[data-testid="new-user-register-button"]').click()
      }
    })

    //cy.get('input[id="new_user_password"]').type(Cypress.env('gitlab_password'))
    //cy.get('button[data-testid="new-user-register-button"]').click()

    //Validate redirect back to sign in and no errors occurred
    //cy.url().should('include', '/users/sign_in')
  })
})

describe('Gitlab Login as Root and Approve User', () => {
  it('Check admin is able to login', () => {
    // test login
    cy.visit(`${Cypress.env('url')}/users/sign_in`)
    cy.performGitlabLogin('root', Cypress.env('adminpassword'))

    // approve new user
    cy.visit(`${Cypress.env('url')}/admin/users?filter=blocked_pending_approval&search_query=${Cypress.env('gitlab_email')}&sort=name_asc`)
    //cy.get('div[data-testid="user-actions-dropdown-toggle"] > button').click()
    //cy.get('li[data-testid="approve"] > button').click()
    //cy.get('button[data-testid="approve-user-confirm-button"]').click()

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
  it('Check if KC SSO or Non-SSO user is able to create/delete a project', () => {

    // clear user data before starting test
    cy.clearAllUserData()

    // test login
    cy.visit(`${Cypress.env('url')}/users/sign_in`)
    if (Cypress.env('keycloak_test_enable')) {
      cy.performKeycloakLogin(Cypress.env('keycloak_username'), Cypress.env('keycloak_password'))
    } else {
      cy.performGitlabLogin(Cypress.env('gitlab_username'), Cypress.env('gitlab_password'))
    }

    // if first login assign Developer role with the joining_team objective
    cy.url().then(($url) => {
      if ($url.includes('welcome')) {
        cy.get('select#user_role').select('software_developer')
        cy.get('select#user_registration_objective').select('code_storage')
        cy.get('button[type="submit"]').click()
      }
    })

    // If project does not exist, create it
    cy.get('body').then($body => {
      if ($body.find('.project-row').length === 0) {
        cy.createGitlabProject(Cypress.env('url'), Cypress.env('gitlab_project'))
      }
    })

    // Cleanup: delete the just-created gitlab project
    cy.deleteGitlabProject(Cypress.env('url'), Cypress.env('gitlab_username'), Cypress.env('gitlab_project'))
  })

  it('Login as Root and Delete Test User', () => {
   // clear user data before starting test
   cy.clearAllUserData()

   //Sign in as Root
   cy.visit(`${Cypress.env('url')}/users/sign_in`)
   cy.performGitlabLogin('root', Cypress.env('adminpassword'))

   //Browse to created user and delete
   cy.visit(`${Cypress.env('url')}/admin/users/${Cypress.env('gitlab_username')}`)
   cy.get(`div[data-qa-username="${Cypress.env('gitlab_username')}"]`).find('button[data-testid="base-dropdown-toggle"]').click()
   cy.get('li[data-testid="delete-deleteWithContributions"]').find('button').click()
   cy.get('input[name="username"]').type(`${Cypress.env('gitlab_first_name')} ${Cypress.env('gitlab_last_name')}`)
   cy.contains('span', 'Delete user and contributions').click({force: true})
  })
})