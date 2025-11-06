targetScope = 'subscription'

param p_policy object

resource r_policy 'Microsoft.Authorization/policyDefinitions@2025-03-01' = {
  name: p_policy.name
  properties: p_policy.properties
}
