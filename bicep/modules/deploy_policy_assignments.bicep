targetScope = 'managementGroup'

param p_policy_assignment_role array

var v_policy_assignments_roles_mg_scope = filter(
  p_policy_assignment_role,
  pa => startsWith(pa.properties.scope, '/providers/Microsoft.Management/managementGroups')
)

var v_policy_assignments_roles_sub_scope = filter(
  p_policy_assignment_role,
  pa => startsWith(pa.properties.scope, '/subscriptions') && !contains(pa.properties.scope, 'resourcegroups')
)

var v_policy_assignments_roles_rg_scope = filter(
  p_policy_assignment_role,
  pa => startsWith(pa.properties.scope, '/subscriptions') && contains(pa.properties.scope, 'resourcegroups')
)

module m_mg_policy_assignments './deploy_policy_assignments/policy_assignment_mg.bicep' = [
  for policy_assignment_roles in v_policy_assignments_roles_mg_scope: {
    scope: managementGroup(split(policy_assignment_roles.properties.scope, '/')[4])
    params: {
      p_policy_assignment_role: policy_assignment_roles
    }
  }
]

module m_sub_policy_assignments './deploy_policy_assignments/policy_assignment_sub.bicep' = [
  for policy_assignment_roles in v_policy_assignments_roles_sub_scope: {
    scope: subscription(split(policy_assignment_roles.properties.scope, '/')[2])
    params: {
      p_policy_assignment_role: policy_assignment_roles
    }
  }
]

module m_rg_policy_assignments './deploy_policy_assignments/policy_assignment_rg.bicep' = [
  for policy_assignment_roles in v_policy_assignments_roles_rg_scope: {
    scope: resourceGroup(
      split(policy_assignment_roles.properties.scope, '/')[2],
      split(policy_assignment_roles.properties.scope, '/')[4]
    )
    params: {
      p_policy_assignment_role: policy_assignment_roles
    }
  }
]
