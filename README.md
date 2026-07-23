# salesforce-scheduler-utilities

Apex invocable actions and supporting types that extend Salesforce Scheduler
(Lightning Scheduler) for use in Flows and custom booking components —
covering territory/resource lookups, multi-resource appointment slot
retrieval, and service appointment creation.

## Apex Classes

### Invocable Actions

| Class | Description |
| --- | --- |
| [`GetWorkTypeGroupTerritories`](force-app/main/default/classes/GetWorkTypeGroupTerritories.cls) | Returns the Service Territories associated with a given Work Type Group. |
| [`GetWorkTypeForTerritory`](force-app/main/default/classes/GetWorkTypeForTerritory.cls) | Returns the Work Type for a given Service Territory and Work Type Group combination. |
| [`GetTerritoryServiceResources`](force-app/main/default/classes/GetTerritoryServiceResources.cls) | Returns active service resources (Technicians and Assets) for a territory, filtered by Work Type Group shifts. |
| [`AppointmentCandidatesInvocable`](force-app/main/default/classes/AppointmentCandidatesInvocable.cls) | Fetches available appointment slots for a Service Appointment via the Lightning Scheduler `getAppointmentSlots` API, supporting single- and multi-resource requests. |
| [`SerializeServiceResources`](force-app/main/default/classes/SerializeServiceResources.cls) | Serializes a primary resource and required resources into the JSON shape expected by the LWC Select Service Appointment Time component. |
| [`CreateServiceAppointment`](force-app/main/default/classes/CreateServiceAppointment.cls) | Creates a Service Appointment and its Assigned Resource records for the primary and required resources. |

### Supporting Types

| Class | Description |
| --- | --- |
| [`AppointmentSlot`](force-app/main/default/classes/AppointmentSlot.cls) | Apex-defined type representing a single available appointment slot; deserializes the JSON response from `getAppointmentSlots`. |

## Development

To work on this project in a scratch org:

1. [Set up CumulusCI](https://cumulusci.readthedocs.io/en/latest/tutorial.html)
2. Run `cci flow run dev_org --org dev` to deploy this project.
3. Run `cci org browser dev` to open the org in your browser.