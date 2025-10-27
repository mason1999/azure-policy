targetScope = 'managementGroup'

param p_policy_assignment_roles object

resource r_policy_assignment 'Microsoft.Authorization/policyAssignments@2025-03-01' = {
  name: p_policy_assignment_roles.properties.name
  location: p_policy_assignment_roles.properties.location
  identity: !contains(p_policy_assignment_roles, 'identity') || p_policy_assignment_roles.identity == null
    ? null
    : { type: 'SystemAssigned' }
  properties: {
    policyDefinitionId: p_policy_assignment_roles.properties.policyDefinitionId
    displayName: p_policy_assignment_roles.properties.?displayName
    description: p_policy_assignment_roles.properties.?description
    metadata: p_policy_assignment_roles.properties.?metadata
    enforcementMode: p_policy_assignment_roles.properties.?enforcementMode
    definitionVersion: p_policy_assignment_roles.properties.?definitionVersion
    nonComplianceMessages: p_policy_assignment_roles.properties.?nonComplianceMessages
    resourceSelectors: p_policy_assignment_roles.properties.?resourceSelectors
    overrides: p_policy_assignment_roles.properties.?overrides
    notScopes: p_policy_assignment_roles.properties.?notScopes
    parameters: p_policy_assignment_roles.properties.?parameters
    assignmentType: 'Custom'
  }
}

// TODO: do this. Step (1) group by user assigned identity and role. Step (2) merge roles together. Step (3) existing resource to get principal id. Step (4) role assignment
// var v_policy_assignments_roles_managed_identity = filter(
//   p_policy_assignment_roles,
//   pa => pa.identity.type == 'UserAssigned'
// )

output x object = {
  principalId: r_policy_assignment.identity.principalId
  roles: p_policy_assignment_roles.properties.roles
}
