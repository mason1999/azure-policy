targetScope = 'managementGroup'

param p_initiatives array

var v_initiatives_mg_scope = filter(
  p_initiatives,
  initiative => startsWith(initiative.id, '/providers/Microsoft.Management/managementGroups')
)

var v_initiatives_sub_scope = filter(p_initiatives, initiative => startsWith(initiative.id, '/subscriptions'))

module m_mg_initiatives './modules/deploy_initiative_mg.bicep' = [
  for initiative in v_initiatives_mg_scope: {
    scope: managementGroup(split(initiative.id, '/')[4])
    params: {
      p_initiative: initiative
    }
  }
]

module m_sub_initiatives './modules/deploy_initiative_sub.bicep' = [
  for initiative in v_initiatives_sub_scope: {
    scope: subscription(split(initiative.id, '/')[2])
    params: {
      p_initiative: initiative
    }
  }
]
