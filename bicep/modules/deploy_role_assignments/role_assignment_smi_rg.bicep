targetScope = 'resourceGroup'

param p_smi_role_assignment object

resource r_policy_assignment 'Microsoft.Authorization/policyAssignments@2025-03-01' existing = {
  name: p_smi_role_assignment.name
}

resource r_role_assignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(tenant().tenantId, p_smi_role_assignment.name, p_smi_role_assignment.role, p_smi_role_assignment.scope)
  properties: {
    principalId: r_policy_assignment.identity.principalId
    roleDefinitionId: p_smi_role_assignment.role
    principalType: 'ServicePrincipal'
  }
}
