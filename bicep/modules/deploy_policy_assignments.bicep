targetScope = 'managementGroup'

param p_policy_assignments_roles array

var v_policy_assignments_roles_mg_scope = filter(
  p_policy_assignments_roles,
  pa => startsWith(pa.properties.scope, '/providers/Microsoft.Management/managementGroups')
)

var v_policy_assignments_roles_sub_scope = filter(
  p_policy_assignments_roles,
  pa => startsWith(pa.properties.scope, '/subscriptions') && !contains(pa.properties.scope, 'resourcegroups')
)

var v_policy_assignments_roles_rg_scope = filter(
  p_policy_assignments_roles,
  pa => startsWith(pa.properties.scope, '/subscriptions') && contains(pa.properties.scope, 'resourcegroups')
)

module m_mg_policy_assignments './modules/policy_assignment_mg.bicep' = [
  for policy_assignment_roles in v_policy_assignments_roles_mg_scope: {
    scope: managementGroup(split(policy_assignment_roles.properties.scope, '/')[4])
    params: {
      p_policy_assignment_roles: policy_assignment_roles
    }
  }
]

module m_sub_policy_assignments './modules/policy_assignment_sub.bicep' = [
  for policy_assignment_roles in v_policy_assignments_roles_sub_scope: {
    scope: subscription(split(policy_assignment_roles.properties.scope, '/')[2])
    params: {
      p_policy_assignment_roles: policy_assignment_roles
    }
  }
]

module m_rg_policy_assignments './modules/policy_assignment_rg.bicep' = [
  for policy_assignment_roles in v_policy_assignments_roles_rg_scope: {
    scope: resourceGroup(
      split(policy_assignment_roles.properties.scope, '/')[2],
      split(policy_assignment_roles.properties.scope, '/')[4]
    )
    params: {
      p_policy_assignment_roles: policy_assignment_roles
    }
  }
]

output mg_test array = [
  for i in range(0, length(v_policy_assignments_roles_mg_scope)): m_mg_policy_assignments[i].outputs.x
]

output sub_test array = [
  for i in range(0, length(v_policy_assignments_roles_sub_scope)): m_sub_policy_assignments[i].outputs.x
]

output rg_test array = [
  for i in range(0, length(v_policy_assignments_roles_rg_scope)): m_rg_policy_assignments[i].outputs.x
]
