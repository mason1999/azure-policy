targetScope = 'resourceGroup'

param p_policy_assignment_role object

resource r_policy_assignment 'Microsoft.Authorization/policyAssignments@2025-03-01' = {
  name: p_policy_assignment_role.name
  location: p_policy_assignment_role.location
  identity: p_policy_assignment_role.?identity
  properties: p_policy_assignment_role.properties
}
