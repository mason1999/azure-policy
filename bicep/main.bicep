targetScope = 'managementGroup'

param p_policies array
param p_initiatives array
param p_policy_assignments array

module m_add_roles_policy_assignments './modules/function_add_roles_policy_assignments.bicep' = {
  params: {
    p_policies: p_policies
    p_initiatives: p_initiatives
    p_policy_assignments: p_policy_assignments
  }
}

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
    p_policy_assignments_roles: m_add_roles_policy_assignments.outputs.o_policy_assignments_roles
  }
  dependsOn: [
    m_deploy_policy_definitions
    m_deploy_initiative_definitions
  ]
}

output mg_test array = m_deploy_policy_assignments.outputs.mg_test
output sub_test array = m_deploy_policy_assignments.outputs.sub_test
output rg_test array = m_deploy_policy_assignments.outputs.rg_test
