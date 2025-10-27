targetScope = 'managementGroup'

param p_policies array

var v_policies_mg_scope = filter(
  p_policies,
  policy => startsWith(policy.id, '/providers/Microsoft.Management/managementGroups')
)

var v_policies_sub_scope = filter(p_policies, policy => startsWith(policy.id, '/subscriptions'))

module m_mg_policies './modules/deploy_policy_mg.bicep' = [
  for policy in v_policies_mg_scope: {
    scope: managementGroup(split(policy.id, '/')[4])
    params: {
      p_policy: policy
    }
  }
]

module m_sub_policies './modules/deploy_policy_sub.bicep' = [
  for policy in v_policies_sub_scope: {
    scope: subscription(split(policy.id, '/')[2])
    params: {
      p_policy: policy
    }
  }
]
