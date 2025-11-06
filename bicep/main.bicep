// import * as object_functions from 'functions/object_functions.bicep'
import * as policy_functions from 'functions/functions.bicep'

targetScope = 'managementGroup'

param p_policies array
param p_initiatives array
param p_policy_assignments array
param p_role_dictionary object

var policy_assignments = policy_functions.create_policy_assignments_role_definition_id(
  p_policies,
  p_initiatives,
  p_policy_assignments,
  p_role_dictionary
)

module m_deploy_policy_definitions './modules/deploy_policy_definitions.bicep' = {
  params: {
    p_policies: p_policies
  }
}

module m_deploy_initiative_definitions './modules/deploy_initiative_definitions.bicep' = {
  params: {
    p_initiatives: p_initiatives
  }
  dependsOn: [
    m_deploy_policy_definitions
  ]
}

module m_deploy_policy_assignments './modules/deploy_policy_assignments.bicep' = {
  params: {
    p_policy_assignment_role: policy_assignments
  }
  dependsOn: [
    m_deploy_policy_definitions
    m_deploy_initiative_definitions
  ]
}

module m_deploy_role_assignments './modules/deploy_role_assignments.bicep' = {
  params: {
    p_policy_assignment_role: policy_assignments
  }
  dependsOn: [
    m_deploy_policy_assignments
  ]
}
