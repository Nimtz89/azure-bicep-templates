//Parameterized version of https://docs.microsoft.com/en-us/azure/templates/microsoft.containerservice/managedclusters?tabs=bicep
//allowed characters for name: letters, numbers, underscores and hyphens
param name string //required
param kubernetesVersion string
param dnsprefix string
param isPrivateCluster bool
param fqdnSubdomain string = ''
param numberOfAgents int
//Documentation for vmSizes can be found here, https://docs.microsoft.com/en-us/azure/virtual-machines/sizes
param vmSize string
//disk size 0 will apply default osDisk size according to specified vmSize
param osDiskSizeGB int = 0
//Can not be changes after creation
@allowed([
  ''
  'Managed'
  'Ephemeral'
])
param osDiskType string = ''
param vnetSubnetID string = ''
param podSubnetID string = ''
param maxPods int = 50
@allowed([
  'Linux'
  'Windows'
])
param osType string
@allowed([
  'Ubuntu'
  'CBLMariner'
])
param osSKU string = 'Ubuntu'
param maxAutoscaleNodes int = 6
param mixAutoscaleNodes int = 2
param enableAutoScaling bool
@allowed([
  'VirtualMachineScaleSet'
  'AvailabilitySet'
])
param agentPoolType string
@allowed([
  'System'
  'User'
])
param agentPoolMode string
//if empty uses AKS default
param upgradeSettingsMaxSurge string
param orchestratorVersion string
param availabilityZones array = []
param enableNodePublicIP bool
param nodePublicIPPrefixID string = ''
@allowed([
  'Spot'
  'Regular'
])
param scaleSetPriority string = 'Regular'
@allowed([
  'Delete'
  'Deallocate'
])
param scaleSetEvictionPolicy string = 'Delete'
param spotMaxPrice string = '' 
param tags object = {}
param nodeLabels object = {}
param nodeTaints array = []
param proximityPlacementGroupID string = ''
param enableEncryptionAtHost bool = true
param enableFIPS bool = false
param gpuInstanceProfile string = ''
param agentPoolName string //required

param LinuxAdminUsername string //required if linux profile is defined
param LinuxPublicKey string //required if linux profile is defined

param windowsAdminUsername string //required if windows profile is defined
param windowsAdminPassword string //required if windows profile is defined
param windowsLicenseType string
param windowsEnableCSIProxy bool = false

param servicePrincipalClientID string
param servicePrincipalSecret string

param enablePodIdentityProfile bool = false
param allowNetworkPluginKubenet bool = false

param nodeResourceGroup string //required
param enableRBAC bool = false
param enablePodSecurityPolicy bool = false


var location = resourceGroup().location
var isOSLinux = osType == 'Linux'
var PoolTypeVMScaleSet = agentPoolType == 'VirtualMachineScaleSet'


resource symbolicname 'Microsoft.ContainerService/managedClusters@2021-03-01' = {
  name: name
  location: location
  tags: {}
  properties: {
    kubernetesVersion: kubernetesVersion
    dnsPrefix: dnsprefix
    fqdnSubdomain: ((isPrivateCluster) ? fqdnSubdomain : json('null'))
    agentPoolProfiles: [
      {
        count: numberOfAgents
        vmSize: 'vmSize'
        osDiskSizeGB: osDiskSizeGB
        osDiskType: ((!empty(osDiskType)) ?  osDiskType : json('null'))
        kubeletDiskType: 'OS'
        vnetSubnetID: ((!empty(vnetSubnetID)) ?  vnetSubnetID : json('null'))
        podSubnetID: ((!empty(podSubnetID)) ?  podSubnetID : json('null'))
        maxPods: maxPods
        osType: osType
        osSKU: ((isOSLinux) ? osSKU : json('null'))
        maxCount: maxAutoscaleNodes
        minCount: mixAutoscaleNodes
        enableAutoScaling: enableAutoScaling
        type: agentPoolType
        mode: agentPoolMode
        orchestratorVersion: orchestratorVersion
        upgradeSettings: {
          maxSurge: upgradeSettingsMaxSurge
        }
        availabilityZones: ((PoolTypeVMScaleSet) ? availabilityZones : json('null'))
        enableNodePublicIP: enableNodePublicIP
        nodePublicIPPrefixID: ((!empty(nodePublicIPPrefixID)) ?  nodePublicIPPrefixID : json('null'))
        scaleSetPriority: scaleSetPriority
        scaleSetEvictionPolicy: scaleSetEvictionPolicy
        spotMaxPrice: ((!empty(spotMaxPrice)) ?  any(spotMaxPrice) : json('null'))
        tags: tags
        nodeLabels: nodeLabels
        nodeTaints: ((!empty(nodeTaints)) ?  nodeTaints : json('null'))
        proximityPlacementGroupID: ((!empty(proximityPlacementGroupID)) ?  proximityPlacementGroupID : json('null'))
        enableEncryptionAtHost: enableEncryptionAtHost
        enableFIPS: enableFIPS
        gpuInstanceProfile: ((!empty(gpuInstanceProfile)) ?  gpuInstanceProfile : json('null'))
        name: agentPoolName
      }
    ]
    linuxProfile: {
      adminUsername: LinuxAdminUsername
      ssh: {
        publicKeys: [
          {
            keyData: LinuxPublicKey
          }
        ]
      }
    }
    windowsProfile: {
      adminUsername: windowsAdminUsername
      adminPassword: windowsAdminPassword
      licenseType: windowsLicenseType
      enableCSIProxy: windowsEnableCSIProxy
    }
    servicePrincipalProfile: {
      clientId: servicePrincipalClientID
      secret: servicePrincipalSecret
    }
    podIdentityProfile: {
      enabled: enablePodIdentityProfile
      allowNetworkPluginKubenet: allowNetworkPluginKubenet
      userAssignedIdentities: [
        {
          name: 'string'
          namespace: 'string'
          bindingSelector: 'string'
          identity: {
            resourceId: 'string'
            clientId: 'string'
            objectId: 'string'
          }
        }
      ]
      userAssignedIdentityExceptions: [
        {
          name: 'string'
          namespace: 'string'
          podLabels: {}
        }
      ]
    }
    nodeResourceGroup: nodeResourceGroup
    enableRBAC: enableRBAC
    enablePodSecurityPolicy: enablePodSecurityPolicy
    identityProfile: {}
  }
  identity: {
    type: 'string'
    userAssignedIdentities: {}
  }
  sku: {
    name: 'Basic'
    tier: 'Free'
  }
}
