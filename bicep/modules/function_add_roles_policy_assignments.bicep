targetScope = 'managementGroup'

param p_policies array
param p_initiatives array
param p_policy_assignments array

var v_policy_to_roles = reduce(
  p_policies,
  {},
  (accumulator, policy) =>
    union(accumulator, { '${policy.id}': policy.properties.policyRule.then.?details.?roleDefinitionIds })
)

var v_policies_to_roles_lower = mapValues(v_policy_to_roles, value => map(value, role => toLower(role)))

var v_policies_to_roles_lower_sorted = mapValues(v_policies_to_roles_lower, value => sort(value, (r1, r2) => r1 < r2))

var v_initiatives_to_policies = reduce(
  p_initiatives,
  {},
  (accumulator, initiative) =>
    union(accumulator, {
      '${initiative.id}': map(
        initiative.properties.policyDefinitions,
        policy_definition => policy_definition.policyDefinitionId
      )
    })
)

var v_initiatives_to_roles = mapValues(
  v_initiatives_to_policies,
  value => reduce(value, [], (accumulator, current_policy) => union(accumulator, v_policy_to_roles[current_policy]))
)

var v_initiatives_to_roles_lower = mapValues(v_initiatives_to_roles, value => map(value, role => toLower(role)))

var v_initiatives_to_roles_lower_sorted = mapValues(
  v_initiatives_to_roles_lower,
  value => sort(value, (r1, r2) => r1 < r2)
)

var v_policy_assignments_roles = [
  for pa in p_policy_assignments: union(
    pa,
    contains(pa.properties.policyDefinitionId, 'policySetDefinitions')
      ? {
          properties: {
            roles: v_initiatives_to_roles_lower_sorted[pa.properties.policyDefinitionId]
          }
        }
      : {
          properties: {
            roles: v_policies_to_roles_lower_sorted[pa.properties.policyDefinitionId]
          }
        }
  )
]

output o_policy_assignments_roles array = v_policy_assignments_roles
