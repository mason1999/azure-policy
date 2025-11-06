import * as object_functions from '../functions/object_functions.bicep'
targetScope = 'managementGroup'

param p_policy_assignment_role array

var v_keep_objects_with_role_and_identity = filter(
  p_policy_assignment_role,
  policy_assignment => contains(policy_assignment, 'role') && contains(policy_assignment, 'identity')
)

var v_update_scope = [
  for pa in v_keep_objects_with_role_and_identity: object_functions.object_update_paths(
    pa,
    '.properties.scope',
    '.scope'
  )
]

var smi_role_assignments = [
  for ra in filter(v_update_scope, value => value.identity.type == 'SystemAssigned'): object_functions.retain_object_keys(
    ra,
    ['name', 'scope', 'role']
  )
]

var umi_role_assignments = [
  for ra in filter(v_update_scope, value => value.identity.type == 'UserAssigned'): object_functions.retain_object_keys(
    ra,
    ['identity', 'scope', 'role']
  )
]

var umi_role_assignments_unique = union(umi_role_assignments, [])

var v_policy_assignments_role_smi_mg_scope = filter(
  smi_role_assignments,
  ra => startsWith(ra.scope, '/providers/Microsoft.Management/managementGroups')
)

var v_policy_assignments_role_smi_sub_scope = filter(
  smi_role_assignments,
  ra => startsWith(ra.scope, '/subscriptions') && !contains(ra.scope, 'resourcegroups')
)

var v_policy_assignments_role_smi_rg_scope = filter(
  smi_role_assignments,
  ra => startsWith(ra.scope, '/subscriptions') && contains(ra.scope, 'resourcegroups')
)

var v_policy_assignments_role_umi_mg_scope = filter(
  umi_role_assignments_unique,
  ra => startsWith(ra.scope, '/providers/Microsoft.Management/managementGroups')
)

var v_policy_assignments_role_umi_sub_scope = filter(
  umi_role_assignments_unique,
  ra => startsWith(ra.scope, '/subscriptions') && !contains(ra.scope, 'resourcegroups')
)

var v_policy_assignments_role_umi_rg_scope = filter(
  umi_role_assignments_unique,
  ra => startsWith(ra.scope, '/subscriptions') && contains(ra.scope, 'resourcegroups')
)

module role_assignment_smi_mg './deploy_role_assignments/role_assignment_smi_mg.bicep' = [
  for role_assignment in v_policy_assignments_role_smi_mg_scope: {
    scope: managementGroup(split(role_assignment.scope, '/')[4])
    params: {
      p_smi_role_assignment: role_assignment
    }
  }
]

module role_assignment_smi_sub './deploy_role_assignments/role_assignment_smi_sub.bicep' = [
  for role_assignment in v_policy_assignments_role_smi_sub_scope: {
    scope: subscription(split(role_assignment.scope, '/')[2])
    params: {
      p_smi_role_assignment: role_assignment
    }
  }
]

module role_assignment_smi_rg './deploy_role_assignments/role_assignment_smi_rg.bicep' = [
  for role_assignment in v_policy_assignments_role_smi_rg_scope: {
    scope: resourceGroup(split(role_assignment.scope, '/')[2], split(role_assignment.scope, '/')[4])
    params: {
      p_smi_role_assignment: role_assignment
    }
  }
]

module role_assignment_umi_mg './deploy_role_assignments/role_assignment_umi_mg.bicep' = [
  for role_assignment in v_policy_assignments_role_umi_mg_scope: {
    scope: managementGroup(split(role_assignment.scope, '/')[4])
    params: {
      p_umi_role_assignment: role_assignment
    }
  }
]

module role_assignment_umi_sub './deploy_role_assignments/role_assignment_umi_sub.bicep' = [
  for role_assignment in v_policy_assignments_role_umi_sub_scope: {
    scope: subscription(split(role_assignment.scope, '/')[2])
    params: {
      p_umi_role_assignment: role_assignment
    }
  }
]

module role_assignment_umi_rg './deploy_role_assignments/role_assignment_umi_rg.bicep' = [
  for role_assignment in v_policy_assignments_role_umi_rg_scope: {
    scope: resourceGroup(split(role_assignment.scope, '/')[2], split(role_assignment.scope, '/')[4])
    params: {
      p_umi_role_assignment: role_assignment
    }
  }
]
