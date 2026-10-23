<!-- TethysRisk::riskRegisterView — table rendering (render asElementTable) -->
| Element | Kind | Type | Declared in |
| --- | --- | --- | --- |
| TethysRisk::riskRegister::earthImpactRisk | part | RiskItem |  |
|  | metadata usage |  | TethysRisk::riskRegister::earthImpactRisk |
| totalRisk | attribute | RiskLevel |  |
| probability | attribute | Level | totalRisk |
| impact | attribute | Level | totalRisk |
| statement | attribute | String | TethysRisk::riskRegister::earthImpactRisk |
| owner | attribute | String | TethysRisk::riskRegister::earthImpactRisk |
| likelihood | attribute | Likelihood | TethysRisk::riskRegister::earthImpactRisk |
| consequence | attribute | Consequence | TethysRisk::riskRegister::earthImpactRisk |
| status | attribute | RiskStatus | TethysRisk::riskRegister::earthImpactRisk |
| trend | attribute | Trend | TethysRisk::riskRegister::earthImpactRisk |
| mitigationRequirements | attribute | SystemRequirement | TethysRisk::riskRegister::earthImpactRisk |
| mitigationActions | action | MitigationAction | TethysRisk::riskRegister::earthImpactRisk |
| dispersionAnalysis | action | MitigationAction | mitigationActions |
| dueReview | attribute | String | dispersionAnalysis |
| complete | attribute | Boolean | dispersionAnalysis |
| commandPathDemo | action | MitigationAction | mitigationActions |
| dueReview | attribute | String | commandPathDemo |
| complete | attribute | Boolean | commandPathDemo |
| relatedHazards | attribute | Hazard | TethysRisk::riskRegister::earthImpactRisk |
| relatedFailureModes | attribute | FailureMode | TethysRisk::riskRegister::earthImpactRisk |
| threatenedRequirements | attribute | MissionRequirement | TethysRisk::riskRegister::earthImpactRisk |
| atSrr | snapshot | RiskItem | TethysRisk::riskRegister::earthImpactRisk |
| likelihood | attribute | Likelihood | atSrr |
| atPdr | snapshot | RiskItem | TethysRisk::riskRegister::earthImpactRisk |
| likelihood | attribute | Likelihood | atPdr |
| TethysRisk::riskRegister::targetSizeRisk | part | RiskItem |  |
|  | metadata usage |  | TethysRisk::riskRegister::targetSizeRisk |
| totalRisk | attribute | RiskLevel |  |
| probability | attribute | Level | totalRisk |
| impact | attribute | Level | totalRisk |
| statement | attribute | String | TethysRisk::riskRegister::targetSizeRisk |
| owner | attribute | String | TethysRisk::riskRegister::targetSizeRisk |
| likelihood | attribute | Likelihood | TethysRisk::riskRegister::targetSizeRisk |
| consequence | attribute | Consequence | TethysRisk::riskRegister::targetSizeRisk |
| status | attribute | RiskStatus | TethysRisk::riskRegister::targetSizeRisk |
| trend | attribute | Trend | TethysRisk::riskRegister::targetSizeRisk |
| mitigationRequirements | attribute | SystemRequirement | TethysRisk::riskRegister::targetSizeRisk |
| mitigationActions | action | MitigationAction | TethysRisk::riskRegister::targetSizeRisk |
| radarCampaign | action | MitigationAction | mitigationActions |
| dueReview | attribute | String | radarCampaign |
| complete | attribute | Boolean | radarCampaign |
| inspectorSurveyBeforeCommit | action | MitigationAction | mitigationActions |
| dueReview | attribute | String | inspectorSurveyBeforeCommit |
| complete | attribute | Boolean | inspectorSurveyBeforeCommit |
| relatedHazards | attribute | Hazard | TethysRisk::riskRegister::targetSizeRisk |
| relatedFailureModes | attribute | FailureMode | TethysRisk::riskRegister::targetSizeRisk |
| threatenedRequirements | attribute | MissionRequirement | TethysRisk::riskRegister::targetSizeRisk |
| atSrr | snapshot | RiskItem | TethysRisk::riskRegister::targetSizeRisk |
| likelihood | attribute | Likelihood | atSrr |
| atPdr | snapshot | RiskItem | TethysRisk::riskRegister::targetSizeRisk |
| likelihood | attribute | Likelihood | atPdr |
| TethysRisk::riskRegister::thrusterLifeRisk | part | RiskItem |  |
|  | metadata usage |  | TethysRisk::riskRegister::thrusterLifeRisk |
| totalRisk | attribute | RiskLevel |  |
| probability | attribute | Level | totalRisk |
| impact | attribute | Level | totalRisk |
| statement | attribute | String | TethysRisk::riskRegister::thrusterLifeRisk |
| owner | attribute | String | TethysRisk::riskRegister::thrusterLifeRisk |
| likelihood | attribute | Likelihood | TethysRisk::riskRegister::thrusterLifeRisk |
| consequence | attribute | Consequence | TethysRisk::riskRegister::thrusterLifeRisk |
| status | attribute | RiskStatus | TethysRisk::riskRegister::thrusterLifeRisk |
| trend | attribute | Trend | TethysRisk::riskRegister::thrusterLifeRisk |
| mitigationActions | action | MitigationAction | TethysRisk::riskRegister::thrusterLifeRisk |
| lifeTest | action | MitigationAction | mitigationActions |
| dueReview | attribute | String | lifeTest |
| complete | attribute | Boolean | lifeTest |
| relatedFailureModes | attribute | FailureMode | TethysRisk::riskRegister::thrusterLifeRisk |
| threatenedRequirements | attribute | MissionRequirement | TethysRisk::riskRegister::thrusterLifeRisk |
| atSrr | snapshot | RiskItem | TethysRisk::riskRegister::thrusterLifeRisk |
| likelihood | attribute | Likelihood | atSrr |
| atPdr | snapshot | RiskItem | TethysRisk::riskRegister::thrusterLifeRisk |
| likelihood | attribute | Likelihood | atPdr |
| TethysRisk::riskRegister::proximityOperationsRisk | part | RiskItem |  |
|  | metadata usage |  | TethysRisk::riskRegister::proximityOperationsRisk |
| totalRisk | attribute | RiskLevel |  |
| probability | attribute | Level | totalRisk |
| impact | attribute | Level | totalRisk |
| statement | attribute | String | TethysRisk::riskRegister::proximityOperationsRisk |
| owner | attribute | String | TethysRisk::riskRegister::proximityOperationsRisk |
| likelihood | attribute | Likelihood | TethysRisk::riskRegister::proximityOperationsRisk |
| consequence | attribute | Consequence | TethysRisk::riskRegister::proximityOperationsRisk |
| status | attribute | RiskStatus | TethysRisk::riskRegister::proximityOperationsRisk |
| trend | attribute | Trend | TethysRisk::riskRegister::proximityOperationsRisk |
| mitigationRequirements | attribute | SystemRequirement | TethysRisk::riskRegister::proximityOperationsRisk |
| mitigationActions | action | MitigationAction | TethysRisk::riskRegister::proximityOperationsRisk |
| hardwareInTheLoopCampaign | action | MitigationAction | mitigationActions |
| dueReview | attribute | String | hardwareInTheLoopCampaign |
| complete | attribute | Boolean | hardwareInTheLoopCampaign |
| relatedHazards | attribute | Hazard | TethysRisk::riskRegister::proximityOperationsRisk |
| relatedFailureModes | attribute | FailureMode | TethysRisk::riskRegister::proximityOperationsRisk |
| threatenedRequirements | attribute | MissionRequirement | TethysRisk::riskRegister::proximityOperationsRisk |
| atSrr | snapshot | RiskItem | TethysRisk::riskRegister::proximityOperationsRisk |
| likelihood | attribute | Likelihood | atSrr |
| atPdr | snapshot | RiskItem | TethysRisk::riskRegister::proximityOperationsRisk |
| likelihood | attribute | Likelihood | atPdr |
| TethysRisk::riskRegister::xenonMarginRisk | part | RiskItem |  |
|  | metadata usage |  | TethysRisk::riskRegister::xenonMarginRisk |
| totalRisk | attribute | RiskLevel |  |
| probability | attribute | Level | totalRisk |
| impact | attribute | Level | totalRisk |
| statement | attribute | String | TethysRisk::riskRegister::xenonMarginRisk |
| owner | attribute | String | TethysRisk::riskRegister::xenonMarginRisk |
| likelihood | attribute | Likelihood | TethysRisk::riskRegister::xenonMarginRisk |
| consequence | attribute | Consequence | TethysRisk::riskRegister::xenonMarginRisk |
| status | attribute | RiskStatus | TethysRisk::riskRegister::xenonMarginRisk |
| trend | attribute | Trend | TethysRisk::riskRegister::xenonMarginRisk |
| mitigationActions | action | MitigationAction | TethysRisk::riskRegister::xenonMarginRisk |
| tankGrowthOption | action | MitigationAction | mitigationActions |
| dueReview | attribute | String | tankGrowthOption |
| complete | attribute | Boolean | tankGrowthOption |
| threatenedRequirements | attribute | MissionRequirement | TethysRisk::riskRegister::xenonMarginRisk |
| atSrr | snapshot | RiskItem | TethysRisk::riskRegister::xenonMarginRisk |
| likelihood | attribute | Likelihood | atSrr |
| atPdr | snapshot | RiskItem | TethysRisk::riskRegister::xenonMarginRisk |
| likelihood | attribute | Likelihood | atPdr |
| TethysRisk::riskRegister::captureBagTechnology | part | TechnologyRisk |  |
|  | metadata usage |  | TethysRisk::riskRegister::captureBagTechnology |
| totalRisk | attribute | RiskLevel |  |
| probability | attribute | Level | totalRisk |
| impact | attribute | Level | totalRisk |
| technicalRisk | attribute | RiskLevel |  |
| probability | attribute | Level | technicalRisk |
| impact | attribute | Level | technicalRisk |
| scheduleRisk | attribute | RiskLevel |  |
| probability | attribute | Level | scheduleRisk |
| impact | attribute | Level | scheduleRisk |
| statement | attribute | String | TethysRisk::riskRegister::captureBagTechnology |
| owner | attribute | String | TethysRisk::riskRegister::captureBagTechnology |
| likelihood | attribute | Likelihood | TethysRisk::riskRegister::captureBagTechnology |
| consequence | attribute | Consequence | TethysRisk::riskRegister::captureBagTechnology |
| status | attribute | RiskStatus | TethysRisk::riskRegister::captureBagTechnology |
| trend | attribute | Trend | TethysRisk::riskRegister::captureBagTechnology |
| readinessNow | attribute | Natural | TethysRisk::riskRegister::captureBagTechnology |
| readinessNeeded | attribute | Natural | TethysRisk::riskRegister::captureBagTechnology |
| fallback | attribute | String | TethysRisk::riskRegister::captureBagTechnology |
| mitigationActions | action | MitigationAction | TethysRisk::riskRegister::captureBagTechnology |
| vacuumDeploymentTest | action | MitigationAction | mitigationActions |
| dueReview | attribute | String | vacuumDeploymentTest |
| complete | attribute | Boolean | vacuumDeploymentTest |
| relatedFailureModes | attribute | FailureMode | TethysRisk::riskRegister::captureBagTechnology |
| threatenedRequirements | attribute | MissionRequirement | TethysRisk::riskRegister::captureBagTechnology |
| atSrr | snapshot | RiskItem | TethysRisk::riskRegister::captureBagTechnology |
| likelihood | attribute | Likelihood | atSrr |
| atPdr | snapshot | RiskItem | TethysRisk::riskRegister::captureBagTechnology |
| likelihood | attribute | Likelihood | atPdr |
