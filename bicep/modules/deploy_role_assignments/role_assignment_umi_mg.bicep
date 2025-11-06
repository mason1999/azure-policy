targetScope = 'managementGroup'

param p_umi_role_assignment object

var user_assigned_managed_identity_resource_id = objectKeys(p_umi_role_assignment.identity.userAssignedIdentities)[0]
var resource_id_array = split(user_assigned_managed_identity_resource_id, '/')
var subscription_id = resource_id_array[2]
var resource_group_name = resource_id_array[4]
var managed_identity_name = resource_id_array[8]

resource r_user_assigned_managed_identity 'Microsoft.ManagedIdentity/userAssignedIdentities@2025-01-31-preview' existing = {
  scope: resourceGroup(subscription_id, resource_group_name)
  name: managed_identity_name
}

resource r_role_assignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(
    tenant().tenantId,
    user_assigned_managed_identity_resource_id,
    p_umi_role_assignment.role,
    p_umi_role_assignment.scope
  )
  properties: {
    principalId: r_user_assigned_managed_identity.properties.principalId
    roleDefinitionId: p_umi_role_assignment.role
    principalType: 'ServicePrincipal'
  }
}
