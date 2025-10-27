targetScope = 'managementGroup'

param p_initiative object

resource r_initiative 'Microsoft.Authorization/policySetDefinitions@2025-03-01' = {
  name: p_initiative.name
  properties: p_initiative.properties
}
