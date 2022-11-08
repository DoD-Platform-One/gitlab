Cypress.on('uncaught:exception', (err, runnable) => {
  // returning false here prevents Cypress from failing the test
  // gitlab throws this error in the console which by default fails the cypress test
  return false
})

describe('Create Gitlab Project', () => {
  it('Check user is able to create a project', () => {
    // test login
    // cy.visit(Cypress.env('url')('/users/sign_in'))
    cy.visit('/users/sign_in')
    cy.get('input[id="user_login"]').type(Cypress.env('gitlab_username'))
    cy.get('input[id="user_password"]').type(Cypress.env('gitlab_password'))
    cy.get('button[type="submit"][name="button"]').click()
    
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