<#
# AUTHOR : Pierrick Lozach
#>

function New-ICUser() # {{{2
{
# Documentation {{{3
<#
.SYNOPSIS
  Creates a new IC user
.DESCRIPTION
  Creates a new IC user. If password is ommitted, default value is '1234'
.PARAMETER ICSession
  The Interaction Center Session
.PARAMETER ICUser
  The Interaction Center User Identifier
.PARAMETER Password
  The Interaction Center User Password
.PARAMETER Extension
  The Interaction Center User Extension
.PARAMETER HasClientAccess
  If true, user is allowed to access the Interaction Client or Desktop applications. Default value is true.
.PARAMETER LicenseActive
  If true, assigned licenses should be considered active by the server. Default value is true.
.PARAMETER MediaLevel
  Used to configure how many interaction types an ACD user can handle at a specified time. Set to 0 for None, 1, 2 or 3. Default value is 3.
.PARAMETER AdditionalLicenses
  List of additional licenses to assign to the user.
.PARAMETER NTDomainUser
  Domain user. Use Domain\User. If ommitted, no Domain User will be assigned to this CIC user.
.PARAMETER PreferredLanguage
  Preferred Language. Use the ISO 63901 code (i.e. en-US for American English, fr for French (France). Default value is the same language as installed on the server (system default).
.PARAMETER Roles
  Collection of roles to assign to this user. i.e. "Administrator, Supervisor"
.PARAMETER SecurityRights
  Set to '*' to assign all security rights. Default sets no rights.
.PARAMETER AccessRights
  Set to '*' to assign all access rights. Default sets no rights.
.PARAMETER AdministrativeRights
  Set to '*' to assign all administrative rights. Default sets no rights.
#> # }}}3
  [CmdletBinding()]
  Param(
    [Parameter(Mandatory=$true)] [Alias("Session", "Id")] [ININ.ICSession] $ICSession,
    [Parameter(Mandatory=$true)] [Alias("User")] [string] $ICUser,
    [Parameter(Mandatory=$false)] [string] $Password,
    [Parameter(Mandatory=$false)] [string] $Extension,
    [Parameter(Mandatory=$false)] [Alias("ClientAccess")] [boolean] $HasClientAccess,
    [Parameter(Mandatory=$false)] [Alias("EnableLicenses", "ActivateLicenses")] [boolean] $LicenseActive,
    [Parameter(Mandatory=$false)] [Alias("MediaLicense")] [int] $MediaLevel,
    [Parameter(Mandatory=$false)] [string[]] $AdditionalLicenses,
    [Parameter(Mandatory=$false)] [Alias("DomainUser")] [string] $NTDomainUser,
    [Parameter(Mandatory=$false)] [Alias("Language")] [string] $PreferredLanguage,
    [Parameter(Mandatory=$false)] [string[]] $Roles,
    [Parameter(Mandatory=$false)] [string] $SecurityRights,
    [Parameter(Mandatory=$false)] [string] $AccessRights,
    [Parameter(Mandatory=$false)] [string] $AdministrativeRights
  )

  $userExists = Get-ICUser $ICSession -ICUser $ICUser
  if (-not ([string]::IsNullOrEmpty($userExists))) {
    return
  }

  # Validate Parameters
  if (!$PSBoundParameters.ContainsKey('Password'))
  {
    $Password = '1234'
  }

  if (!$PSBoundParameters.ContainsKey('HasClientAccess'))
  {
    $HasClientAccess = $true
  }

  if (!$PSBoundParameters.ContainsKey('LicenseActive'))
  {
    $LicenseActive = $true
  }

  if (!$PSBoundParameters.ContainsKey('MediaLevel'))
  {
    $MediaLevel = 3
  }

  # Add headers
  $headers = @{
    "Accept-Language"      = $ICSession.language;
    "ININ-ICWS-CSRF-Token" = $ICSession.token;
  }

  # Build base body
  $body = @{
   "configurationId" = New-ICConfigurationId $ICUser
   "extension" = $Extension
  }

  ############
  # Licenses #
  ############
  $licenseProperties = @{
    "hasClientAccess" = $HasClientAccess
    "licenseActive" = $LicenseActive
    "mediaLevel" = $MediaLevel
  }

  # Add Additional Licenses if there are any
  if ($AdditionalLicenses) {
    # Add all licenses?
    if ($AdditionalLicenses.Length -eq 1 -and $AdditionalLicenses[0] -eq "*") {
      $allAdditionalLicenses = ((Get-ICLicenseAllocations $cic).items | foreach { if (-not ($_.configurationId.id -match "EASYSCRIPTER" -or $_.configurationId.id -match "MSCRM")) { $_.configurationId } })
      # Add missing licenses
      $allAdditionalLicenses += New-ICConfigurationId "I3_ACCESS_IPAD_USER_SUPERVISOR"
      $allAdditionalLicenses += New-ICConfigurationId "I3_OPTIMIZER_SHOWRTA"
      $allAdditionalLicenses += New-ICConfigurationId "I3_OPTIMIZER_SCHEDULABLE"

      $licenseProperties.Add("additionalLicenses", $allAdditionalLicenses)
    }
    else {
      $licenseProperties += @{
        "additionalLicenses" = @( $AdditionalLicenses | foreach { New-ICConfigurationId $_ } )
      }
    }
  }

  if (![string]::IsNullOrEmpty($licenseProperties)) {
    $body += @{
     "licenseProperties" = $licenseProperties
    }
  }

  ##################
  # NT Domain User #
  ##################
  if (![string]::IsNullOrEmpty($NTDomainUser)) {
    $body += @{
      "ntDomainUser" = $NTDomainUser
    }
  }

  ######################
  # Preferred Language #
  ######################
  if (![string]::IsNullOrEmpty($PreferredLanguage)) {
    $body += @{
      "preferredLanguage" = @{
        "id" = $PreferredLanguage
      }
    }
  }

  #########
  # Roles #
  #########
  if ($Roles) {
    $body += @{
      "roles" = @( $Roles | foreach { @{ "id" = $_ } })
    }
  }

  ###################
  # Security Rights #
  ###################
  # There is no "All" parameter. You have to specify each security right individually.
  if (![string]::IsNullOrEmpty($SecurityRights)) {
    $body += @{
      "securityRights" = @{
        "accessAllInteractionConferences" = @{
          "actualValue" = $true
        }
        "accessOwnedInteractionConferences" = @{
          "actualValue" = $true
        }
        "accountCodeVerification" = @{
          "actualValue" = $true
        }
        "addIndividuals" = @{
          "actualValue" = $true
        }
        "addOrganizations" = @{
          "actualValue" = $true
        }
        "agentPreferences" = @{
          "actualValue" = $true
        }
        "allowAccessToProblemReporter" = @{
          "actualValue" = $true
        }
        "allowAgentRules" = @{
          "actualValue" = $true
        }
        "allowAgentScheduleBidding" = @{
          "actualValue" = $true
        }
        "allowAgentSeeOwnRank" = @{
          "actualValue" = $true
        }
        "allowAgentSeeRelativeRank" = @{
          "actualValue" = $true
        }
        "allowAlertProgramming" = @{
          "actualValue" = $true
        }
        "allowEmailAccessViaTui" = @{
          "actualValue" = $true
        }
        "allowEmailAlerts" = @{
          "actualValue" = $true
        }
        "allowFaxAccessViaTui" = @{
          "actualValue" = $true
        }
        "allowHandlerAlerts" = @{
          "actualValue" = $true
        }
        "allowIntercomChat" = @{
          "actualValue" = $true
        }
        "allowMemoAlerts" = @{
          "actualValue" = $true
        }
        "allowMiniMode" = @{
          "actualValue" = $true
        }
        "allowMonitorColumns" = @{
          "actualValue" = $true
        }
        "allowMultipleCalls" = @{
          "actualValue" = $true
        }
        "allowPersistentConnections" = @{
          "actualValue" = $true
        }
        "allowReceiveVoicemail" = @{
          "actualValue" = $true
        }
        "allowRelatedInteractionsPage" = @{
          "actualValue" = $true
        }
        "allowResponseManagement" = @{
          "actualValue" = $true
        }
        "allowSpeedDials" = @{
          "actualValue" = $true
        }
        "allowStatusNotes" = @{
          "actualValue" = $true
        }
        "allowUserDefinedTelephoneNumberOnRemoteLogin" = @{
          "actualValue" = $true
        }
        "allowVideo" = @{
          "actualValue" = $true
        }
        "allowVoiceMaiAccessViaTui" = @{
          "actualValue" = $true
        }
        "allowWorkgroupStats" = @{
          "actualValue" = $true
        }
        "canAccessOptimizerShiftTrading" = @{
          "actualValue" = $true
        }
        "canCoachInteractions" = @{
          "actualValue" = $true
        }
        "canConferenceCalls" = @{
          "actualValue" = $true
        }
        "canCreateEmailAttendantProfile" = @{
          "actualValue" = $true
        }
        "canCreateInboundAttendantProfile" = @{
          "actualValue" = $true
        }
        "canCreateOperatorAttendantProfile" = @{
          "actualValue" = $true
        }
        "canCreateOptimizerActivityCodes" = @{
          "actualValue" = $true
        }
        "canCreateOptimizerDayClassifications" = @{
          "actualValue" = $true
        }
        "canCreateOutboundAttendantProfile" = @{
          "actualValue" = $true
        }
        "canCreateQuestionnaireDirectories" = @{
          "actualValue" = $true
        }
        "canCreateSchedulingUnits" = @{
          "actualValue" = $true
        }
        "canDeleteOptimizerActivityCodes" = @{
          "actualValue" = $true
        }
        "canDeleteOptimizerDayClassifications" = @{
          "actualValue" = $true
        }
        "canDeleteSchedulingUnits" = @{
          "actualValue" = $true
        }
        "canDisconnectInteractions" = @{
          "actualValue" = $true
        }
        "canInitiateSecureInput" = @{
          "actualValue" = $true
        }
        "canJoinInteractions" = @{
          "actualValue" = $true
        }
        "canListenInOnInteractions" = @{
          "actualValue" = $true
        }
        "canManageClientTemplates" = @{
          "actualValue" = $true
        }
        "canModifyOptimizerActivityCodes" = @{
          "actualValue" = $true
        }
        "canModifyOptimizerDayClassifications" = @{
          "actualValue" = $true
        }
        "canModifyOptimizerStatusActivityTypeMapping" = @{
          "actualValue" = $true
        }
        "canMuteInteractions" = @{
          "actualValue" = $true
        }
        "canOrbitQueue" = @{
          "actualValue" = $true
        }
        "canOverrideFinishedScorecards" = @{
          "actualValue" = $true
        }
        "canParkInteractions" = @{
          "actualValue" = $true
        }
        "canPauseInteractions" = @{
          "actualValue" = $true
        }
        "canPickupInteractions" = @{
          "actualValue" = $true
        }
        "canPublishProcess" = @{
          "actualValue" = $true
        }
        "canPutInteractionsOnHold" = @{
          "actualValue" = $true
        }
        "canRecordInteractions" = @{
          "actualValue" = $true
        }
        "canRequestAssistanceFromSupervisor" = @{
          "actualValue" = $true
        }
        "canSecureRecordingPauseInteractions" = @{
          "actualValue" = $true
        }
        "canSubmitTimeOff" = @{
          "actualValue" = $true
        }
        "canTransferInteractions" = @{
          "actualValue" = $true
        }
        "canTransferInteractionsToVoicemail" = @{
          "actualValue" = $true
        }
        "canUserInteractionRecorderSelector" = @{
          "actualValue" = $true
        }
        "canViewOptimizerActivityCodes" = @{
          "actualValue" = $true
        }
        "canViewOptimizerDayClassifications" = @{
          "actualValue" = $true
        }
        "canViewOptimizerStatusActivityTypeMapping" = @{
          "actualValue" = $true
        }
        "customizeClient" = @{
          "actualValue" = $true
        }
        "debugHandlers" = @{
          "actualValue" = $true
        }
        "deleteIndividuals" = @{
          "actualValue" = $true
        }
        "deleteOrganizations" = @{
          "actualValue" = $true
        }
        "directoryAdmin" = @{
          "actualValue" = $true
        }
        "followMe" = @{
          "actualValue" = $true
        }
        "havePrivateContacts" = @{
          "actualValue" = $true
        }
        "interactionRecorderMasterKeyPasswordAdministrator" = @{
          "actualValue" = $true
        }
        "iPPhoneProvisioningAdmin" = @{
          "actualValue" = $true
        }
        "lockPolicySets" = @{
          "actualValue" = $true
        }
        "loginCampaign" = @{
          "actualValue" = $true
        }
        "manageHandlers" = @{
          "actualValue" = $true
        }
        "mobileOfficeUser" = @{
          "actualValue" = $true
        }
        "modifyConfigurationChangeAuditing" = @{
          "actualValue" = $true
        }
        "modifyConfigurationGeneral" = @{
          "actualValue" = $true
        }
        "modifyConfigurationHTTPServer" = @{
          "actualValue" = $true
        }
        "modifyConfigurationOutboundServers" = @{
          "actualValue" = $true
        }
        "modifyConfigurationPhoneNumberTypes" = @{
          "actualValue" = $true
        }
        "modifyConfigurationPreviewCallBehavior" = @{
          "actualValue" = $true
        }
        "modifyIndividuals" = @{
          "actualValue" = $true
        }
        "modifyInteractions" = @{
          "actualValue" = $true
        }
        "modifyOrganizations" = @{
          "actualValue" = $true
        }
        "outlookTuiUser" = @{
          "actualValue" = $true
        }
        "privateCalls" = @{
          "actualValue" = $true
        }
        "publishHandlers" = @{
          "actualValue" = $true
        }
        "remoteControl" = @{
          "actualValue" = $true
        }
        "reporterAdministrator" = @{
          "actualValue" = $true
        }
        "requireForcedAuthorizationCode" = @{
          "actualValue" = $true
        }
        "runContactListPredefinedActions" = @{
          "actualValue" = $true
        }
        "showAssistanceButton" = @{
          "actualValue" = $true
        }
        "showCoachButton" = @{
          "actualValue" = $true
        }
        "showDisconnectButton" = @{
          "actualValue" = $true
        }
        "showHoldButton" = @{
          "actualValue" = $true
        }
        "showJoinButton" = @{
          "actualValue" = $true
        }
        "showListenButton" = @{
          "actualValue" = $true
        }
        "showMuteButton" = @{
          "actualValue" = $true
        }
        "showParkButton" = @{
          "actualValue" = $true
        }
        "showPauseButton" = @{
          "actualValue" = $true
        }
        "showPickupButton" = @{
          "actualValue" = $true
        }
        "showPrivateButton" = @{
          "actualValue" = $true
        }
        "showRecordButton" = @{
          "actualValue" = $true
        }
        "showSecureInputButton" = @{
          "actualValue" = $true
        }
        "showSecureRecordingPauseButton" = @{
          "actualValue" = $true
        }
        "showTransferButton" = @{
          "actualValue" = $true
        }
        "showVoicemailButton" = @{
          "actualValue" = $true
        }
        "showWorkgroupsProfilesTab" = @{
          "actualValue" = $true
        }
        "traceConfiguration" = @{
          "actualValue" = $true
        }
        "trackerAdministrator" = @{
          "actualValue" = $true
        }
        "useTiffForFaxes" = @{
          "actualValue" = $true
        }
        "viewConfigurationChangeAuditing" = @{
          "actualValue" = $true
        }
        "viewConfigurationGeneral" = @{
          "actualValue" = $true
        }
        "viewConfigurationHTTPServer" = @{
          "actualValue" = $true
        }
        "viewConfigurationOutboundServers" = @{
          "actualValue" = $true
        }
        "viewConfigurationPhoneNumberTypes" = @{
          "actualValue" = $true
        }
        "viewConfigurationPreviewCallBehavior" = @{
          "actualValue" = $true
        }
        "viewInteractionDetails" = @{
          "actualValue" = $true
        }
        "viewModifyCampaignAgentlessCallingType" = @{
          "actualValue" = $true
        }
        "viewModifyCampaignAutomaticTimeZoneMapping" = @{
          "actualValue" = $true
        }
        "viewModifyCampaignLineSettings" = @{
          "actualValue" = $true
        }
        "viewModifyCampaignMaxLines" = @{
          "actualValue" = $true
        }
        "viewModifyCampaignStatus" = @{
          "actualValue" = $true
        }
        "viewModifyContactListDataQuery" = @{
          "actualValue" = $true
        }
        "viewModifyCustomHandlerActions" = @{
          "actualValue" = $true
        }
        "viewModifyDatabaseConnections" = @{
          "actualValue" = $true
        }
        "viewModifyDncSources" = @{
          "actualValue" = $true
        }
        "viewModifyEventLog" = @{
          "actualValue" = $true
        }
        "viewModifyTimeZoneMapData" = @{
          "actualValue" = $true
        }
        "viewOtherPeoplesPrivateInteractions" = @{
          "actualValue" = $true
        }
      }
    }
  }

  #################
  # Access Rights #
  #################
  if (![string]::IsNullOrEmpty($AccessRights)) {
    $actualValue = @{
      "grouping" = "0"
      "objectType" = "0"
    }
    $actualValueList = @($actualValue) # This needs to be a list

    $body += @{
      "accessRights" = @{
        "activateOthers" = @{
          "actualValue" = $actualValueList
        }
        "activateSelf" = @{
          "actualValue" = $actualValueList
        }
        "canEditAccessRights" = @{
          "actualValue" = $true
        }
        "changeUserStatus" = @{
          "actualValue" = $actualValueList
        }
        "clientButtons" = @{
          "actualValue" = $actualValueList
        }
        "coachLineQueue" = @{
          "actualValue" = $actualValueList
        }
        "coachStationQueue" = @{
          "actualValue" = $actualValueList
        }
        "coachUserQueue" = @{
          "actualValue" = $actualValueList
        }
        "coachWorkgroupQueue" = @{
          "actualValue" = $actualValueList
        }
        "createOptimizerForecasts" = @{
          "actualValue" = $actualValueList
        }
        "createSchedulingUnitAgentConstraints" = @{
          "actualValue" = $actualValueList
        }
        "createSchedulingUnitAgentGroups" = @{
          "actualValue" = $actualValueList
        }
        "createSchedulingUnitSchedules" = @{
          "actualValue" = $actualValueList
        }
        "createSchedulingUnitShiftRotations" = @{
          "actualValue" = $actualValueList
        }
        "createSchedulingUnitShifts" = @{
          "actualValue" = $actualValueList
        }
        "createSchedulingUnitTimeoffRequests" = @{
          "actualValue" = $actualValueList
        }
        "deleteOptimizerForecasts" = @{
          "actualValue" = $actualValueList
        }
        "deleteSchedulingUnitAgentConstraints" = @{
          "actualValue" = $actualValueList
        }
        "deleteSchedulingUnitAgentGroups" = @{
          "actualValue" = $actualValueList
        }
        "deleteSchedulingUnitSchedules" = @{
          "actualValue" = $actualValueList
        }
        "deleteSchedulingUnitShiftRotations" = @{
          "actualValue" = $actualValueList
        }
        "deleteSchedulingUnitShifts" = @{
          "actualValue" = $actualValueList
        }
        "deleteSchedulingUnitTimeoffRequests" = @{
          "actualValue" = $actualValueList
        }
        "disconnectLineQueue" = @{
          "actualValue" = $actualValueList
        }
        "disconnectStationQueue" = @{
          "actualValue" = $actualValueList
        }
        "disconnectUserQueue" = @{
          "actualValue" = $actualValueList
        }
        "disconnectWorkgroupQueue" = @{
          "actualValue" = $actualValueList
        }
        "eFaqs" = @{
          "actualValue" = $actualValueList
        }
        "followMePhoneNumberClassifications" = @{
          "actualValue" = $actualValueList
        }
        "forwardPhoneNumberClassifications" = @{
          "actualValue" = $actualValueList
        }
        "holdStationQueue" = @{
          "actualValue" = $actualValueList
        }
        "holdUserQueue" = @{
          "actualValue" = $actualValueList
        }
        "interactionClientPlugins" = @{
          "actualValue" = $actualValueList
        }
        "interactionConferenceRestrictRooms" = @{
          "actualValue" = $actualValueList
        }
        "joinLineQueue" = @{
          "actualValue" = $actualValueList
        }
        "joinStationQueue" = @{
          "actualValue" = $actualValueList
        }
        "joinUserQueue" = @{
          "actualValue" = $actualValueList
        }
        "joinWorkgroupQueue" = @{
          "actualValue" = $actualValueList
        }
        "launchableProcessList" = @{
          "actualValue" = $actualValueList
        }
        "listAccountCodes" = @{
          "actualValue" = $actualValueList
        }
        "listenLineQueue" = @{
          "actualValue" = $actualValueList
        }
        "listenStationQueue" = @{
          "actualValue" = $actualValueList
        }
        "listenUserQueue" = @{
          "actualValue" = $actualValueList
        }
        "listenWorkgroupQueue" = @{
          "actualValue" = $actualValueList
        }
        "loginStation" = @{
          "actualValue" = $actualValueList
        }
        "manageProcessList" = @{
          "actualValue" = $actualValueList
        }
        "miscellaneous" = @{
          "actualValue" = $actualValueList
        }
        "modifyAttendantEmailProfiles" = @{
          "actualValue" = $actualValueList
        }
        "modifyAttendantInboundProfiles" = @{
          "actualValue" = $actualValueList
        }
        "modifyAttendantOperatorProfiles" = @{
          "actualValue" = $actualValueList
        }
        "modifyAttendantOutboundProfiles" = @{
          "actualValue" = $actualValueList
        }
        "modifyCampaignList" = @{
          "actualValue" = $actualValueList
        }
        "modifyFeedbackSurveys" = @{
          "actualValue" = $actualValueList
        }
        "modifyOptimizerForecasts" = @{
          "actualValue" = $actualValueList
        }
        "modifyRecorderQuestionnaires" = @{
          "actualValue" = $actualValueList
        }
        "modifySchedulingUnitAgentConstraints" = @{
          "actualValue" = $actualValueList
        }
        "modifySchedulingUnitAgentGroups" = @{
          "actualValue" = $actualValueList
        }
        "modifySchedulingUnitConfiguration" = @{
          "actualValue" = $actualValueList
        }
        "modifySchedulingUnitListRealTimeAdherence" = @{
          "actualValue" = $actualValueList
        }
        "modifySchedulingUnitSchedules" = @{
          "actualValue" = $actualValueList
        }
        "modifySchedulingUnitShiftRotations" = @{
          "actualValue" = $actualValueList
        }
        "modifySchedulingUnitShifts" = @{
          "actualValue" = $actualValueList
        }
        "modifySchedulingUnitTimeoffRequests" = @{
          "actualValue" = $actualValueList
        }
        "muteStationQueue" = @{
          "actualValue" = $actualValueList
        }
        "muteUserQueue" = @{
          "actualValue" = $actualValueList
        }
        "phoneNumberClassifications" = @{
          "actualValue" = $actualValueList
        }
        "pickupLineQueue" = @{
          "actualValue" = $actualValueList
        }
        "pickupStationQueue" = @{
          "actualValue" = $actualValueList
        }
        "pickupUserQueue" = @{
          "actualValue" = $actualValueList
        }
        "pickupWorkgroupQueue" = @{
          "actualValue" = $actualValueList
        }
        "previewEmailUserQueue" = @{
          "actualValue" = $actualValueList
        }
        "previewEmailWorkgroupQueue" = @{
          "actualValue" = $actualValueList
        }
        "recordLineQueue" = @{
          "actualValue" = $actualValueList
        }
        "recordStationQueue" = @{
          "actualValue" = $actualValueList
        }
        "recordUserQueue" = @{
          "actualValue" = $actualValueList
        }
        "recordWorkgroupQueue" = @{
          "actualValue" = $actualValueList
        }
        "responseManagementDocuments" = @{
          "actualValue" = $actualValueList
        }
        "statusMessages" = @{
          "actualValue" = $actualValueList
        }
        "substituteQueueControlColumns" = @{
          "actualValue" = $actualValueList
        }
        "transferLineQueue" = @{
          "actualValue" = $actualValueList
        }
        "transferStationQueue" = @{
          "actualValue" = $actualValueList
        }
        "transferUserQueue" = @{
          "actualValue" = $actualValueList
        }
        "transferWorkgroupQueue" = @{
          "actualValue" = $actualValueList
        }
        "tuiPhoneNumberClassifications" = @{
          "actualValue" = $actualValueList
        }
        "viewAttendantEmailProfileInSearch" = @{
          "actualValue" = $actualValueList
        }
        "viewAttendantEmailProfiles" = @{
          "actualValue" = $actualValueList
        }
        "viewAttendantInboundProfileInSearch" = @{
          "actualValue" = $actualValueList
        }
        "viewAttendantInboundProfiles" = @{
          "actualValue" = $actualValueList
        }
        "viewAttendantOperatorProfileInSearch" = @{
          "actualValue" = $actualValueList
        }
        "viewAttendantOperatorProfiles" = @{
          "actualValue" = $actualValueList
        }
        "viewAttendantOutboundProfileInSearch" = @{
          "actualValue" = $actualValueList
        }
        "viewAttendantOutboundProfiles" = @{
          "actualValue" = $actualValueList
        }
        "viewCampaignList" = @{
          "actualValue" = $actualValueList
        }
        "viewDataSource" = @{
          "actualValue" = $actualValueList
        }
        "viewFeedbackSurveys" = @{
          "actualValue" = $actualValueList
        }
        "viewGeneralDirectories" = @{
          "actualValue" = $actualValueList
        }
        "viewHistoricalReports" = @{
          "actualValue" = $actualValueList
        }
        "viewIndividualStatistics" = @{
          "actualValue" = $actualValueList
        }
        "viewLayoutList" = @{
          "actualValue" = $actualValueList
        }
        "viewLineQueue" = @{
          "actualValue" = $actualValueList
        }
        "viewModifyOptimizerAll" = @{
          "actualValue" = $actualValueList
        }
        "viewOptimizerForecasts" = @{
          "actualValue" = $actualValueList
        }
        "viewOptimizerSchedulingUnits" = @{
          "actualValue" = $actualValueList
        }
        "viewPositionsList" = @{
          "actualValue" = $actualValueList
        }
        "viewProcessList" = @{
          "actualValue" = $actualValueList
        }
        "viewQueueControlColumns" = @{
          "actualValue" = $actualValueList
        }
        "viewRecorderQuestionnaires" = @{
          "actualValue" = $actualValueList
        }
        "viewReport" = @{
          "actualValue" = $actualValueList
        }
        "viewSchedulingUnitAgentConstraints" = @{
          "actualValue" = $actualValueList
        }
        "viewSchedulingUnitAgentGroups" = @{
          "actualValue" = $actualValueList
        }
        "viewSchedulingUnitConfiguration" = @{
          "actualValue" = $actualValueList
        }
        "viewSchedulingUnitIntradayMonitoring" = @{
          "actualValue" = $actualValueList
        }
        "viewSchedulingUnitListRealTimeAdherence" = @{
          "actualValue" = $actualValueList
        }
        "viewSchedulingUnitSchedulePreferences" = @{
          "actualValue" = $actualValueList
        }
        "viewSchedulingUnitSchedules" = @{
          "actualValue" = $actualValueList
        }
        "viewSchedulingUnitShiftRotations" = @{
          "actualValue" = $actualValueList
        }
        "viewSchedulingUnitShifts" = @{
          "actualValue" = $actualValueList
        }
        "viewSchedulingUnitTimeoffRequests" = @{
          "actualValue" = $actualValueList
        }
        "viewSkillList" = @{
          "actualValue" = $actualValueList
        }
        "viewStationGroups" = @{
          "actualValue" = $actualValueList
        }
        "viewStationGroupsInSearch" = @{
          "actualValue" = $actualValueList
        }
        "viewStationQueue" = @{
          "actualValue" = $actualValueList
        }
        "viewStationQueueInSearch" = @{
          "actualValue" = $actualValueList
        }
        "viewStatusColumns" = @{
          "actualValue" = $actualValueList
        }
        "viewUserInteractionHistory" = @{
          "actualValue" = $actualValueList
        }
        "viewUserQueue" = @{
          "actualValue" = $actualValueList
        }
        "viewWorkgroup" = @{
          "actualValue" = $actualValueList
        }
        "viewWorkgroupQueue" = @{
          "actualValue" = $actualValueList
        }
        "viewWorkgroupQueueInSearch" = @{
          "actualValue" = $actualValueList
        }
        "viewWorkgroupStatistics" = @{
          "actualValue" = $actualValueList
        }
      }
    }
  }

  #########################
  # Administrative Rights #
  #########################
  if (![string]::IsNullOrEmpty($AdministrativeRights)) {
    $actualValue = @{
      "grouping" = "0"
      "objectType" = "0"
    }
    $actualValueList = @($actualValue) # This needs to be a list

    $body += @{
      "administrativeRights" = @{
        "accountCodeList" = @{
          "actualValue" = $actualValueList
        }
        "accumulatorList" = @{
        "actualValue" = $actualValueList
        }
        "actions" = @{
        "actualValue" = $actualValueList
        }
        "attendantDefaults" = @{
        "actualValue" = $true
        }
        "audioSources" = @{
        "actualValue" = $actualValueList
        }
        "canEditAdministrativeRights" = @{
        "actualValue" = $true
        }
        "canPublishClientTemplates" = @{
        "actualValue" = $true
        }
        "clientButtons" = @{
        "actualValue" = $actualValueList
        }
        "clientConfigurationConfiguration" = @{
        "actualValue" = $true
        }
        "clientConfigurationTemplates" = @{
        "actualValue" = $actualValueList
        }
        "collective" = @{
        "actualValue" = $true
        }
        "contactListSources" = @{
        "actualValue" = $actualValueList
        }
        "dataManagerConfiguration" = @{
        "actualValue" = $true
        }
        "defaultIPPhoneConfiguration" = @{
        "actualValue" = $true
        }
        "defaultLocationConfiguration" = @{
        "actualValue" = $true
        }
        "defaultStationConfiguration" = @{
        "actualValue" = $true
        }
        "defaultUserConfiguration" = @{
        "actualValue" = $true
        }
        "dnisMappingsConfiguration" = @{
        "actualValue" = $true
        }
        "eFaq" = @{
        "actualValue" = $actualValueList
        }
        "faxConfiguration" = @{
        "actualValue" = $true
        }
        "faxGroups" = @{
        "actualValue" = $actualValueList
        }
        "handlers" = @{
        "actualValue" = $actualValueList
        }
        "iCDataSources" = @{
        "actualValue" = $actualValueList
        }
        "imageResources" = @{
        "actualValue" = $actualValueList
        }
        "initializationFunctions" = @{
        "actualValue" = $actualValueList
        }
        "interactionAnalyzerKeywordSets" = @{
        "actualValue" = $actualValueList
        }
        "interactionConferenceConfiguration" = @{
        "actualValue" = $true
        }
        "interactionConferenceRooms" = @{
        "actualValue" = $actualValueList
        }
        "interactionDialerCallLists" = @{
        "actualValue" = $actualValueList
        }
        "interactionDialerCampaigns" = @{
        "actualValue" = $actualValueList
        }
        "interactionDialerConfiguration" = @{
        "actualValue" = $true
        }
        "interactionDialerPolicySets" = @{
        "actualValue" = $actualValueList
        }
        "interactionDialerRuleSets" = @{
        "actualValue" = $actualValueList
        }
        "interactionDialerSchedules" = @{
        "actualValue" = $actualValueList
        }
        "interactionDialerScripts" = @{
        "actualValue" = $actualValueList
        }
        "interactionDialerSkillSets" = @{
        "actualValue" = $actualValueList
        }
        "interactionDialerStageSets" = @{
        "actualValue" = $actualValueList
        }
        "interactionDialerZoneSets" = @{
        "actualValue" = $actualValueList
        }
        "interactionFeedbackConfiguration" = @{
        "actualValue" = $true
        }
        "interactionOptimizerAdvancedConfiguration" = @{
        "actualValue" = $true
        }
        "interactionOptimizerAgentsConfiguration" = @{
        "actualValue" = $true
        }
        "interactionProcessAutomation" = @{
        "actualValue" = $true
        }
        "interactionProcessorTables" = @{
        "actualValue" = $actualValueList
        }
        "interactionRecorderConfiguration" = @{
        "actualValue" = $true
        }
        "interactionTrackerConfiguration" = @{
        "actualValue" = $true
        }
        "iPPhoneRegistrationGroups" = @{
        "actualValue" = $actualValueList
        }
        "iPPhoneRingSets" = @{
        "actualValue" = $actualValueList
        }
        "iPPhones" = @{
        "actualValue" = $actualValueList
        }
        "iPPhoneTemplates" = @{
        "actualValue" = $actualValueList
        }
        "layouts" = @{
        "actualValue" = $actualValueList
        }
        "licensesAllocationConfiguration" = @{
        "actualValue" = $true
        }
        "lineGroups" = @{
        "actualValue" = $actualValueList
        }
        "lines" = @{
        "actualValue" = $actualValueList
        }
        "locations" = @{
        "actualValue" = $actualValueList
        }
        "logRetrievalAssistantConfiguration" = @{
        "actualValue" = $true
        }
        "mailConfiguration" = @{
        "actualValue" = $true
        }
        "masterAdministrator" = @{
        "actualValue" = $true
        }
        "mediaServersConfiguration" = @{
        "actualValue" = $true
        }
        "mrcpConfiguration" = @{
        "actualValue" = $true
        }
        "passwordPolicies" = @{
        "actualValue" = $actualValueList
        }
        "passwordPoliciesConfiguration" = @{
        "actualValue" = $true
        }
        "peerSitesConfiguration" = @{
        "actualValue" = $true
        }
        "phoneNumbersConfiguration" = @{
        "actualValue" = $true
        }
        "positions" = @{
        "actualValue" = $actualValueList
        }
        "problemReporterConfiguration" = @{
        "actualValue" = $true
        }
        "queueControlColumns" = @{
        "actualValue" = $actualValueList
        }
        "reportLogs" = @{
        "actualValue" = $actualValueList
        }
        "reports" = @{
        "actualValue" = $actualValueList
        }
        "responseManagement" = @{
        "actualValue" = $actualValueList
        }
        "roles" = @{
        "actualValue" = $actualValueList
        }
        "salesforceCtis" = @{
        "actualValue" = $actualValueList
        }
        "sametimeConfiguration" = @{
        "actualValue" = $true
        }
        "schedules" = @{
        "actualValue" = $actualValueList
        }
        "secureInputForms" = @{
        "actualValue" = $actualValueList
        }
        "selectionRuleList" = @{
        "actualValue" = $actualValueList
        }
        "serverParameter" = @{
        "actualValue" = $actualValueList
        }
        "serversConfiguration" = @{
        "actualValue" = $true
        }
        "sessionManagerServerConfiguration" = @{
        "actualValue" = $true
        }
        "singleSignOnIdentityProviders" = @{
        "actualValue" = $actualValueList
        }
        "singleSignOnSecureTokenServer" = @{
        "actualValue" = $true
        }
        "sipBridge" = @{
        "actualValue" = $actualValueList
        }
        "sipProxyConfiguration" = @{
        "actualValue" = $true
        }
        "skillCategories" = @{
        "actualValue" = $actualValueList
        }
        "skills" = @{
        "actualValue" = $actualValueList
        }
        "smsBroker" = @{
        "actualValue" = $actualValueList
        }
        "smsConfiguration" = @{
        "actualValue" = $true
        }
        "speechRecognitionConfiguration" = @{
        "actualValue" = $true
        }
        "stationGroups" = @{
        "actualValue" = $actualValueList
        }
        "stations" = @{
        "actualValue" = $actualValueList
        }
        "stationTemplates" = @{
        "actualValue" = $actualValueList
        }
        "statisticGroups" = @{
        "actualValue" = $actualValueList
        }
        "statusMessages" = @{
        "actualValue" = $actualValueList
        }
        "structuredParameters" = @{
        "actualValue" = $actualValueList
        }
        "systemConfiguration" = @{
        "actualValue" = $true
        }
        "systemParameters" = @{
        "actualValue" = $actualValueList
        }
        "users" = @{
        "actualValue" = $actualValueList
        }
        "webServicesParameters" = @{
        "actualValue" = $actualValueList
        }
        "workgroups" = @{
        "actualValue" = $actualValueList
        }
        "wrapUpCategories" = @{
        "actualValue" = $actualValueList
        }
        "wrapUpCodes" = @{
        "actualValue" = $actualValueList
        }
      }
    }
  }

  $body = ConvertTo-Json($body) -Depth 4

  # Call it!
  $response = Invoke-RestMethod -Uri "$($ICsession.baseURL)/$($ICSession.id)/configuration/users" -Body $body -Method Post -Headers $headers -WebSession $ICSession.webSession -ErrorAction Stop
  Write-Output $response | Format-Table
  [PSCustomObject] $response
} # }}}2
