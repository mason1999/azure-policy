$input_bicep_param_path = './main.bicepparam'
$output_json_param_path = './main.json'

az bicep build-params -f "${input_bicep_param_path}" --outfile "${output_json_param_path}"
$params = Get-Content $output_json_param_path | ConvertFrom-Json -AsHashTable -Depth 100

foreach ($x in (Get-ChildItem "../policy-definitions")) {
    $current_policy = Get-Content "../policy-definitions/$($x.basename).json" | ConvertFrom-Json -AsHashTable -Depth 100
    $params.parameters.p_policies.value += $current_policy
}
foreach ($x in (Get-ChildItem "../policy-initiatives")) {
    $current_initiative = Get-Content "../policy-initiatives/$($x.basename).json" | ConvertFrom-Json -AsHashTable -Depth 100
    $params.parameters.p_initiatives.value += $current_initiative
}

foreach ($x in (Get-ChildItem "../policy-assignments")) {
    $current_policy_assignment = Get-Content "../policy-assignments/$($x.basename).json" | ConvertFrom-Json -AsHashTable -Depth 100
    $params.parameters.p_policy_assignments.value += $current_policy_assignment
}

$params | ConvertTo-Json -Depth 100 > $output_json_param_path
# az stack sub create --name "test" --location "australiaeast" --template-file "./main.bicep" --parameters $output_json_param_path --action-on-unmanage "deleteAll" --deny-settings-mode "none" --yes
# az stack mg create -m "mason" --name "test" --location "australiaeast" --template-file "./main.bicep" --parameters $output_json_param_path --action-on-unmanage "deleteAll" --deny-settings-mode "none" --yes
az stack mg create -m "1e265494-869d-4d1e-8f63-ca8704d33218" --name "test" --location "australiaeast" --template-file "./main.bicep" --parameters $output_json_param_path --action-on-unmanage "deleteAll" --deny-settings-mode "none" --yes
Remove-Item -Path $output_json_param_path


# az bicep build-params -f $input_bicep_param_path --outfile $output_json_param_path
# $params = Get-Content $output_json_param_path | ConvertFrom-Json -AsHashTable -Depth 100
# foreach ($x in (Get-ChildItem "policy-definitions")) {
#     $current_policy = Get-Content "policy-definitions/$($x.basename).json" | ConvertFrom-Json -AsHashTable -Depth 100
#     $params.parameters.policies.value += $current_policy
# }
# $policy_1 = Get-Content "policy-definitions/policy1.json" | ConvertFrom-Json -AsHashTable -Depth 100
# $initiative_12 = Get-Content "policy-initiatives/init12.json" | ConvertFrom-Json -AsHashTable -Depth 100
# $params.parameters.p_policy.value = $policy_1
# $params.parameters.p_initiative.value = $initiative_12
# $params | ConvertTo-Json -Depth 100 > $output_json_param_path
# az stack sub create --name "test" --location "australiaeast" --template-file "./main.bicep" --parameters $output_json_param_path --action-on-unmanage "deleteAll" --deny-settings-mode "none" --yes
# Remove-Item -Path $output_json_param_path
