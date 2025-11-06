import * as object_functions from './object_functions.bicep'
@export()
func create_policy_to_roles_object(p_policies array) object =>
  mapValues(
    reduce(
      p_policies,
      {},
      (accumulator, policy) =>
        union(accumulator, {
          '${policy.id}': contains(['modify', 'deployIfNotExists'], policy.properties.policyRule.then.effect)
            ? policy.properties.policyRule.then.?details.?roleDefinitionIds
            : []
        })
    ),
    value => map(value, role => toLower(role))
  )

@export()
func create_initiatives_to_roles_object(p_policies array, p_initiatives array) object =>
  mapValues(
    reduce(
      p_initiatives,
      {},
      (accumulator, initiative) =>
        union(accumulator, {
          '${initiative.id}': map(
            initiative.properties.policyDefinitions,
            policy_definition => policy_definition.policyDefinitionId
          )
        })
    ),
    policy_ids =>
      reduce(
        policy_ids,
        {
          state: {
            create_policy_to_roles_object: create_policy_to_roles_object(p_policies)
          }
          roles: []
        },
        (accumulator, policy_id) =>
          union(accumulator, {
            roles: union(accumulator.state.create_policy_to_roles_object[policy_id], accumulator.roles)
          })
      ).roles
  )

@export()
func create_policy_assignments_with_roles(p_policies array, p_initiatives array, p_policy_assignments array) array =>
  reduce(
    p_policy_assignments,
    {
      state: {
        policy_to_roles: create_policy_to_roles_object(p_policies)
        initiatives_to_roles: create_initiatives_to_roles_object(p_policies, p_initiatives)
      }
      policy_assignments: []
    },
    (accumulator, policy_assignment) =>
      contains(
          policy_assignment.properties.policyDefinitionId,
          '/providers/Microsoft.Authorization/policySetDefinitions/'
        )
        ? union(accumulator, {
            policy_assignments: union(accumulator.policy_assignments, [
              shallowMerge([
                policy_assignment
                {
                  properties: object_functions.delete_object_keys(
                    policy_assignment.properties,
                    ['name', 'location', 'id']
                  )
                  id: policy_assignment.properties.id
                  name: policy_assignment.properties.name
                  location: policy_assignment.properties.location
                  roles: accumulator.state.initiatives_to_roles[policy_assignment.properties.policyDefinitionId]
                }
              ])
            ])
          })
        : union(accumulator, {
            policy_assignments: union(accumulator.policy_assignments, [
              shallowMerge([
                policy_assignment
                {
                  properties: object_functions.delete_object_keys(
                    policy_assignment.properties,
                    ['name', 'location', 'id']
                  )
                  id: policy_assignment.properties.id
                  name: policy_assignment.properties.name
                  location: policy_assignment.properties.location
                  roles: accumulator.state.policy_to_roles[policy_assignment.properties.policyDefinitionId]
                }
              ])
            ])
          })
  ).policy_assignments

@export()
func create_policy_assignments_role(p_policies array, p_initiatives array, p_policy_assignments array) array =>
  reduce(
    create_policy_assignments_with_roles(p_policies, p_initiatives, p_policy_assignments),
    [],
    (accumulator, item) => union(accumulator, object_functions.create_array_from_object_field(item, 'roles', 'role'))
  )

@export()
func create_policy_assignments_role_definition_id(
  p_policies array,
  p_initiatives array,
  p_policy_assignments array,
  p_role_dictionary object
) array =>
  reduce(
    create_policy_assignments_role(p_policies, p_initiatives, p_policy_assignments),
    [],
    (accumulator, policy_assignment) =>
      union(accumulator, [
        shallowMerge([
          policy_assignment
          contains(policy_assignment, 'role') ? { role: p_role_dictionary[split(policy_assignment.role, '/')[4]] } : {}
        ])
      ])
  )
