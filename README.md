# DSPI
Dynamic Stream Processing Interface

## This repository contains the following items:
### [TedTCL](PartialReconfiguration/tedtcl/) - a TCL library for aiding blocker generation.
### [TedTCL Blocking Test](PartialReconfiguration/BlockerTestSuccessful/) - an example PR module generation
### [TedTCL Blocking Test (Overconstrained)](PartialReconfiguration/BlockerTest/) - overconstrained blocker to test whether Vivado will comply or break it.
### [Support modules](SupportModules/)
### [Module templates](TemplateModules/)
### [Interface definition for Vivado](VivadoInterfaceDefinition/)
### [Example modules for ZCU102](ZCU102/):
#### [Filter (Large)](ZCU102/Filter_32_4_BDMMBDMDMM/)
#### [Filter (Medium)](ZCU102/Filter_16_2_DMDMM/)
#### [Filter (Small)](ZCU102/Filter_8_1_MDMM/)
#### [Support empty column B](ZCU102/EmptyColumn_B/)
#### [Support empty column D](ZCU102/EmptyColumn_D/)
#### [Support empty column M](ZCU102/EmptyColumn_M/)
#### [Support pipelined column M forward direction](ZCU102/PipelineColumnDirOne_M/)
#### [Support pipelined column M backward direction](ZCU102/PipelineColumnDirTwo_M/)
#### [Support empty turnaround column M](ZCU102/TurnAround_M/)
