# Data archive (Meridian Vault) design description

## Purpose

*Component definition*

| name | type | documentation |
| --- | --- | --- |
| DataArchive |  | Meridian Vault, the archive: catalogues every product level with a checksum,<br>keeps each by its retention rule and distributes the released levels. |

## Ports

*Ports of the component*

| name | type | documentation |
| --- | --- | --- |
| ingest | TethysMeridian::ProductPort |  |
| distribution | TethysMeridian::ProductPort |  |

## Figures and tables

*Attributes the component carries*

| name | type | documentation |
| --- | --- | --- |
| productName |  |  |
| version |  |  |
| l0Rule | TethysGroundSoftware::RetentionRule |  |
| l1Rule | TethysGroundSoftware::RetentionRule |  |
| l2Rule | TethysGroundSoftware::RetentionRule |  |
| l3Rule | TethysGroundSoftware::RetentionRule |  |
| rules | TethysGroundSoftware::RetentionRule |  |
| checksumWidth | ScalarValues::Natural |  |
| catalogued | ScalarValues::Natural |  |
| distributedLevels | ScalarValues::Natural |  |

*Parts the component owns*

| name | type | documentation |
| --- | --- | --- |

## Requirements satisfied

*Software requirements satisfied*

| name | satisfies | rows |
| --- | --- | --- |
| dataArchive | archiveRetention | 1 |

## Assurance classification

*Classification register row*

| name | level | documentation |
| --- | --- | --- |
| dataArchive | levelD | Meridian Vault: the archive. |

One volume per component of the Meridian Operations Suite, in the order of TethysGroundSoftware::MeridianOperationsSuite::components. Every table is a query over TethysGroundSoftware, TethysSoftwareRequirements, TethysSoftwareAssurance and TethysVerification.
