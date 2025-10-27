#! /usr/bin/bash

readonly SCRIPT_PATH=$(readlink -m $(dirname $0))

print_json_schema_boilerplate() {
  local provider=$1
  output=$(
    printf "{\n"
      printf "\t\"\$schema\": \"https://json-schema.org/draft-07/schema#\",\n"
      printf "\t\"definitions\": {\n"
      printf "\t\t\"aliases\": {\n"
      printf "\t\t\"type\": \"string\",\n"
      printf "\t\t\"pattern\": \"^${provider}\",\n"
      printf "\t\t\"examples\": [\n"
      IFS=$'\t\n '
      mapfile aliases <<< $(az provider show --namespace $provider --expand 'resourceTypes/aliases' --query 'resourceTypes[].aliases[].name' --output tsv)
      read length <<< ${#aliases[@]}
      for (( i = 0; i < length; i++ )); do
        if (( i == length - 1 )); then
          printf "\t\t\t\t\"%s\"\n" ${aliases[$i]}
          break
        fi
        printf "\t\t\t\t\"%s\",\n" ${aliases[$i]}
      done
      printf "\t\t\t]\n"
      printf "\t\t}\n"
      printf "\t}\n"
    printf "}\n"
  )
  if type -p jq &>/dev/null; then
    printf "%s\n" "$output" | jq
    exit 0
  fi
  printf "%s\n" "$output"
}

print_microsoft_providers_cache() {
  local provider=""
  declare -a microsoft_providers
  microsoft_providers=(
    Microsoft.AAD
    Microsoft.AadCustomSecurityAttributesDiagnosticSettings
    Microsoft.Addons
    Microsoft.ADHybridHealthService
    Microsoft.Advisor
    Microsoft.AgFoodPlatform
    Microsoft.AgriculturePlatform
    Microsoft.AlertsManagement
    Microsoft.AnalysisServices
    Microsoft.ApiCenter
    Microsoft.ApiManagement
    Microsoft.App
    Microsoft.AppAssessment
    Microsoft.AppComplianceAutomation
    Microsoft.AppConfiguration
    Microsoft.ApplicationMigration
    Microsoft.AppLink
    Microsoft.AppPlatform
    Microsoft.ArcContainerStorage
    Microsoft.Attestation
    Microsoft.Authorization
    Microsoft.Automanage
    Microsoft.Automation
    Microsoft.AVS
    Microsoft.AwsConnector
    Microsoft.AzureActiveDirectory
    Microsoft.AzureArcData
    Microsoft.AzureBusinessContinuity
    Microsoft.AzureDataTransfer
    Microsoft.AzureFleet
    Microsoft.AzureImageTestingForLinux
    Microsoft.AzureLargeInstance
    Microsoft.AzurePlaywrightService
    Microsoft.AzureResilienceManagement
    Microsoft.AzureScan
    Microsoft.AzureSphere
    Microsoft.AzureStack
    Microsoft.AzureStackHCI
    Microsoft.AzureTerraform
    Microsoft.BackupSolutions
    Microsoft.BareMetal
    Microsoft.BareMetalInfrastructure
    Microsoft.Batch
    Microsoft.Billing
    Microsoft.BillingBenefits
    Microsoft.Bing
    Microsoft.BlockchainTokens
    Microsoft.Blueprint
    Microsoft.BotService
    Microsoft.Cache
    Microsoft.Capacity
    Microsoft.Carbon
    Microsoft.Cdn
    Microsoft.CertificateRegistration
    Microsoft.ChangeAnalysis
    Microsoft.ChangeSafety
    Microsoft.Chaos
    Microsoft.ClassicCompute
    Microsoft.ClassicInfrastructureMigrate
    Microsoft.ClassicNetwork
    Microsoft.ClassicStorage
    Microsoft.ClassicSubscription
    Microsoft.CleanRoom
    Microsoft.CloudDevicePlatform
    Microsoft.CloudHealth
    Microsoft.CloudShell
    Microsoft.CloudTest
    Microsoft.CodeSigning
    Microsoft.CognitiveServices
    Microsoft.Commerce
    Microsoft.Communication
    Microsoft.Community
    Microsoft.Compute
    Microsoft.ComputeSchedule
    Microsoft.ConfidentialLedger
    Microsoft.Confluent
    Microsoft.ConnectedCache
    Microsoft.ConnectedCredentials
    Microsoft.ConnectedVehicle
    Microsoft.ConnectedVMwarevSphere
    Microsoft.Consumption
    Microsoft.ContainerInstance
    Microsoft.ContainerRegistry
    Microsoft.ContainerService
    Microsoft.CostManagement
    Microsoft.CostManagementExports
    Microsoft.CustomerLockbox
    Microsoft.CustomProviders
    Microsoft.D365CustomerInsights
    Microsoft.Dashboard
    Microsoft.DatabaseFleetManager
    Microsoft.DatabaseWatcher
    Microsoft.DataBox
    Microsoft.DataBoxEdge
    Microsoft.Databricks
    Microsoft.Datadog
    Microsoft.DataFactory
    Microsoft.DataLakeAnalytics
    Microsoft.DataLakeStore
    Microsoft.DataMigration
    Microsoft.DataProtection
    Microsoft.DataReplication
    Microsoft.DataShare
    Microsoft.DBforMariaDB
    Microsoft.DBforMySQL
    Microsoft.DBforPostgreSQL
    Microsoft.DependencyMap
    Microsoft.DesktopVirtualization
    Microsoft.DevCenter
    Microsoft.DevelopmentWindows365
    Microsoft.DevHub
    Microsoft.DeviceOnboarding
    Microsoft.DeviceRegistry
    Microsoft.Devices
    Microsoft.DeviceUpdate
    Microsoft.DevOpsInfrastructure
    Microsoft.DevTestLab
    Microsoft.DigitalTwins
    Microsoft.Discovery
    Microsoft.DocumentDB
    Microsoft.DomainRegistration
    Microsoft.DurableTask
    Microsoft.Easm
    Microsoft.Edge
    Microsoft.EdgeManagement
    Microsoft.EdgeMarketplace
    Microsoft.EdgeOrder
    Microsoft.EdgeOrderPartner
    Microsoft.EdgeZones
    Microsoft.Elastic
    Microsoft.ElasticSan
    Microsoft.EnterpriseSupport
    Microsoft.EntitlementManagement
    Microsoft.EntraIDGovernance
    Microsoft.ErrorAtlas
    Microsoft.EventGrid
    Microsoft.EventHub
    Microsoft.Experimentation
    Microsoft.ExtendedLocation
    Microsoft.Fabric
    Microsoft.Features
    Microsoft.FileShares
    Microsoft.FluidRelay
    Microsoft.GCPConnector
    Microsoft.GraphServices
    Microsoft.GuestConfiguration
    Microsoft.HanaOnAzure
    Microsoft.HardwareSecurityModules
    Microsoft.HDInsight
    Microsoft.HealthBot
    Microsoft.HealthcareApis
    Microsoft.HealthcareInterop
    Microsoft.HealthDataAIServices
    Microsoft.HealthModel
    Microsoft.HealthPlatform
    Microsoft.Help
    Microsoft.HybridCloud
    Microsoft.HybridCompute
    Microsoft.HybridConnectivity
    Microsoft.HybridContainerService
    Microsoft.HybridNetwork
    Microsoft.Impact
    Microsoft.IntegrationSpaces
    Microsoft.IoTCentral
    Microsoft.IoTFirmwareDefense
    Microsoft.IoTOperations
    Microsoft.IoTOperationsDataProcessor
    Microsoft.IoTSecurity
    Microsoft.KeyVault
    Microsoft.Kubernetes
    Microsoft.KubernetesConfiguration
    Microsoft.KubernetesRuntime
    Microsoft.Kusto
    Microsoft.LabServices
    Microsoft.LoadTestService
    Microsoft.Logic
    Microsoft.MachineLearningServices
    Microsoft.Maintenance
    Microsoft.ManagedIdentity
    Microsoft.ManagedNetworkFabric
    Microsoft.ManagedServices
    Microsoft.Management
    Microsoft.Maps
    Microsoft.Marketplace
    Microsoft.MarketplaceOrdering
    Microsoft.MessagingCatalog
    Microsoft.MessagingConnectors
    Microsoft.Migrate
    Microsoft.Mission
    Microsoft.MixedReality
    Microsoft.Monitor
    Microsoft.MySQLDiscovery
    Microsoft.NetApp
    Microsoft.Network
    Microsoft.NetworkCloud
    Microsoft.NetworkFunction
    Microsoft.NexusIdentity
    Microsoft.NotificationHubs
    Microsoft.Nutanix
    Microsoft.ObjectStore
    Microsoft.OffAzure
    Microsoft.OffAzureSpringBoot
    Microsoft.OnlineExperimentation
    Microsoft.OpenEnergyPlatform
    Microsoft.OperationalInsights
    Microsoft.OperationsManagement
    Microsoft.OperatorVoicemail
    Microsoft.OracleDiscovery
    Microsoft.Orbital
    Microsoft.PartnerManagedConsumerRecurrence
    Microsoft.Peering
    Microsoft.Pki
    Microsoft.PolicyInsights
    Microsoft.Portal
    Microsoft.PortalServices
    Microsoft.PowerBI
    Microsoft.PowerBIDedicated
    Microsoft.PowerPlatform
    Microsoft.Premonition
    Microsoft.ProfessionalService
    Microsoft.ProviderHub
    Microsoft.Purview
    Microsoft.Quantum
    Microsoft.Quota
    Microsoft.RecommendationsService
    Microsoft.RecoveryServices
    Microsoft.RedHatOpenShift
    Microsoft.Relationships
    Microsoft.Relay
    Microsoft.ResourceConnector
    Microsoft.ResourceGraph
    Microsoft.ResourceHealth
    Microsoft.ResourceIntelligence
    Microsoft.ResourceNotifications
    Microsoft.Resources
    Microsoft.SaaS
    Microsoft.SaaSHub
    Microsoft.Scom
    Microsoft.SCVMM
    Microsoft.Search
    Microsoft.SecretSyncController
    Microsoft.Security
    Microsoft.SecurityCopilot
    Microsoft.SecurityDetonation
    Microsoft.SecurityInsights
    Microsoft.SecurityPlatform
    Microsoft.SentinelPlatformServices
    Microsoft.SerialConsole
    Microsoft.ServiceBus
    Microsoft.ServiceFabric
    Microsoft.ServiceFabricMesh
    Microsoft.ServiceLinker
    Microsoft.ServiceNetworking
    Microsoft.ServicesHub
    Microsoft.SignalRService
    Microsoft.Singularity
    Microsoft.SoftwarePlan
    Microsoft.Solutions
    Microsoft.Sovereign
    Microsoft.Sql
    Microsoft.SqlVirtualMachine
    Microsoft.StandbyPool
    Microsoft.Storage
    Microsoft.StorageActions
    Microsoft.StorageCache
    Microsoft.StorageDiscovery
    Microsoft.StorageMover
    Microsoft.StorageSync
    Microsoft.StorageTasks
    Microsoft.StreamAnalytics
    Microsoft.Subscription
    Microsoft.SupercomputerInfrastructure
    Microsoft.SustainabilityServices
    Microsoft.Synapse
    Microsoft.Syntex
    Microsoft.ToolchainOrchestrator
    Microsoft.UpdateManager
    Microsoft.UsageBilling
    Microsoft.VerifiedId
    Microsoft.VideoIndexer
    Microsoft.VirtualMachineImages
    Microsoft.VMware
    Microsoft.VoiceServices
    Microsoft.Web
    Microsoft.WeightsAndBiases
    Microsoft.Windows365
    Microsoft.WindowsPushNotificationServices
    Microsoft.WorkloadBuilder
    Microsoft.Workloads
  )
  for provider in "${microsoft_providers[@]}"; do
    printf "%s\n" $provider
  done
}

error_log() {
  printf "\e[91mError: $1\e[97m\n" >&2
  exit 1
}

usage() {
    sect() {
        printf "\e[97m${1@U}\n\e[0m"
    }
    line() {
        printf "\t$1\n"
    }
    # Indentation doesn't do anything. just meant for readability.
    sect "overview:"
        line ""
        line "This script scrapes the aliases of a given provider into a folder (schemas/providers/<provider>/aliases.json)."
        line "If the <provder> folder does not exist, it will be created. If it already exists the aliases.json will be overwritten."
        line "The script does assume the following folder structure:"
        line ".vscode"
        line "├── helpers"
        line "│   └── \e[35mimport-aliases.sh (<= script is here)\e[0m"
        line "├── schemas"
        line "│   ├── policy-definition-schema.json"
        line "│   ├── policy-initiative-schema.json"
        line "│   └── providers"
        line "│       ├── \e[35mMicrosoft.Compute (<= Will create/overwrite aliases.json file in folder here)\e[0m"
        line "│       ├── \e[35mMicrosoft.Network (<= Will create/overwrite aliases.json file in folder here)\e[0m"
        line "│       ├── \e[35mMicrosoft.Storage (<= Will create/overwrite aliases.json file in folder here)\e[0m"
        line "│       ├── ... etc"
        line "│       └── \e[35mMicrosoft.App (<= Will create/overwrite aliases.json file in folder here)\e[0m"
        line "└── settings.json"
        line ""
    sect "usage:"
        line "\e[31m"
        line ".vscode/helpers/import-aliases [OPTIONS] [<provider name>]"
        line "\e[0m"
    sect "examples:"
        line "\e[32m"
        line ".vscode/helpers/import-aliases --help" 
        line ".vscode/helpers/import-aliases -h" 
        line ".vscode/helpers/import-aliases -lc"
        line ".vscode/helpers/import-aliases --list-providers --cache"
        line ".vscode/helpers/import-aliases --provider Microsoft.Compute"
        line ".vscode/helpers/import-aliases --provider=Microsoft.Network"
        line ".vscode/helpers/import-aliases -p Microsoft.Storage"
        line ".vscode/helpers/import-aliases -p=Microsoft.Management"
        line "\e[0m"
    sect "options:"
        line "\e[34m"
        line "-h,--help : (Switch) Outputs help menu."
        line "-l,--list-providers : (Switch) Lists the providers which start with Microsoft. Can use this as input to the -p parameter."
        line "-c,--cache : (Switch) To be used with the '-l' flag or the '-p' flag. When used Microsoft providers or aliases are listed from a cache in memory."
        line "-p,--provider : (Value) The name of the microsoft provider whose aliases we would like to import."
        line "-d,--dry-run : (Switch) To be used with the '-p' flag. When used, providers are not touched but just outputted to stdout."
        line "\e[0m"
    unset sect
    unset line
}

parse_args() {
  args=""
  for x in "$@"; do
    args="$args${x}\""
  done
  args=${args//=/\"}
  args=${args%%\"}
  IFS=$'"'
  set -- $args
  while [[ "${1}" != '' ]]; do
    case $1 in 
      --provider|-p) provider=$2; shift; shift;;
      --list-providers|-l) list_providers_flag=true; shift;;
      --cache|-c) cache_flag=true; shift;;
      --dry-run|-d) dry_run_flag=true; shift;;
      --help|-h) help_flag=true; shift;;
      -[a-zA-Z]*)
        opstring=${1##-}
        for (( i = 0; i < ${#opstring}; i++ )); do
          if (( $i == ${#opstring} - 1 )); then
            case "-${opstring:i:1}" in 
              -p) provider=$2; shift;;
              -d) dry_run_flag=true;;
              -l) list_providers_flag=true;;
              -c) cache_flag=true;;
              -h) help_flag=true;;
            esac
            shift;
            break
          fi
          case "-${opstring:i:1}" in 
            -d) dry_run_flag=true; continue;;
            -l) list_providers_flag=true; continue;;
            -c) cache_flag=true; continue;;
            -h) help_flag=true; continue;;
          esac
        done
      ;;
      -*) error_log "argument '$1' unrecognized"
    esac
  done
}
########## BEGIN SCRIPT ##########
parse_args "$@"

if [[ -z "$@" ]] || [[ "${help_flag}" == "true" ]]; then
  usage
  exit 0
fi

if [[ ! -z "${list_providers_flag}" ]];then
  if [[ ! -z "${cache_flag}" ]]; then
    print_microsoft_providers_cache
    exit 0
  fi
  az provider list --query "[?starts_with(namespace, 'Microsoft')].namespace" --output tsv
  exit 0
fi

if [[ ! -z "${provider}" ]]; then

  exec 10>/dev/tty

  if [[ -z "${cache_flag}" ]] && [[ -z "${dry_run_flag}" ]]; then
    printf "creating provider aliases for ${provider} with no cache in JSON format...\n" >&10
    mkdir -p "${SCRIPT_PATH}/../schemas/providers/${provider}"
    print_json_schema_boilerplate "${provider}" > "${SCRIPT_PATH}/../schemas/providers/${provider}/aliases.json"
    exit 0
  fi

  if [[ -z "${cache_flag}" ]] && [[ ! -z "${dry_run_flag}" ]]; then
    printf "Outputting provider alises for ${provider} with no cache in JSON format...\n" >&10
    print_json_schema_boilerplate "${provider}"
    exit 0
  fi

  if [[ ! -z "${cache_flag}" ]] && [[ ! -z "${dry_run_flag}" ]]; then
    printf "Outputting provider alises for ${provider} with cache in JSON format...\n" >&10
    if [[ -e "${SCRIPT_PATH}/../schemas/providers/${provider}/aliases.json" ]]; then
      cat "${SCRIPT_PATH}/../schemas/providers/${provider}/aliases.json"
    else
      error_log "There is no cache to read from for provider: ${provider}."
    fi
    exit 0
  fi

fi
