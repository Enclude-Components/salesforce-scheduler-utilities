/**
 * @description Invocable class that retrieves available appointment slots for a given
 *              work type, service territory, and service appointment using the Lightning
 *              Scheduler API.
 *
 *              Required resources are derived from the AssignedResource records on the
 *              service appointment. The primary resource is identified by IsPrimaryResource,
 *              and additional required resources by IsRequiredResource.
 *
 * @author      Brandon DeMatteis, Enclude
 * @since       24/03/2026
 * @group       Scheduling
 */
@SuppressWarnings('PMD.AvoidGlobalModifier')
global without sharing class AppointmentCandidatesInvocable {
    /**
     * @description Invocable method that fetches available appointment slots.
     * @param requests List of Request objects
     * @return List of Result objects, each containing a collection of AppointmentSlot records
     */
    @InvocableMethod(label='Get Appointment Candidates' category='Scheduling' iconName='slds:standard:event')
    global static Result[] execute(Request[] requests) {
        Set<Id> saIds = new Set<Id>();
        for (Request request : requests) {
            saIds.add(request.serviceAppointmentId);
        }

        Map<Id, ServiceAppointment> saMap = new Map<Id, ServiceAppointment>([
            SELECT WorkTypeId, ServiceTerritoryId,
                (SELECT ServiceResourceId, IsPrimaryResource
                 FROM ServiceResources
                 WHERE IsRequiredResource = true)
            FROM ServiceAppointment
            WHERE Id IN :saIds
            WITH SYSTEM_MODE
        ]);

        Result[] responses = new Result[]{};
        for (Request request : requests) {
            ServiceAppointment sa = saMap.get(request.serviceAppointmentId);
            if (sa == null) {
                throw new IllegalArgumentException(
                    'No Service Appointment found with ID ' + request.serviceAppointmentId
                );
            }
            List<AssignedResource> assignedResources = sa.ServiceResources;

            String primaryResourceId;
            List<String> additionalResourceIds = new List<String>();
            for (AssignedResource ar : assignedResources) {
                if (ar.IsPrimaryResource) {
                    primaryResourceId = ar.ServiceResourceId;
                } else {
                    additionalResourceIds.add(ar.ServiceResourceId);
                }
            }

            if (primaryResourceId == null && additionalResourceIds.isEmpty()) {
                responses.add(new Result());
                continue;
            }

            lxscheduler.WorkType workType = new lxscheduler.WorkTypeBuilder()
                .setId(sa.WorkTypeId)
                .build();

            lxscheduler.GetAppointmentSlotsInputBuilder builder = new lxscheduler.GetAppointmentSlotsInputBuilder()
                .setWorkType(workType)
                .setTerritoryIds(new List<String>{ sa.ServiceTerritoryId })
                .setApiVersion(Double.valueOf('66.0'));

            if (additionalResourceIds.isEmpty()) {
                // Single resource — pass as requiredResourceIds only
                builder.setRequiredResourceIds(new List<String>{ primaryResourceId });
            } else {
                // Multi-resource — primary separate, additional as required
                builder.setPrimaryResourceId(primaryResourceId);
                builder.setRequiredResourceIds(additionalResourceIds);
            }

            String response = lxscheduler.SchedulerResources.getAppointmentSlots(builder.build());

            Result result = new Result();
            result.slots = AppointmentSlot.fromGetAppointmentSlotsResponse(response);
            responses.add(result);
        }
        return responses;
    }

    /**
     * @description Input parameters for the invocable method.
     */
    global class Request {
        @InvocableVariable(label='Service Appointment ID' required=true)
        global String serviceAppointmentId;
    }

    /**
     * @description Output for the invocable method.
     *              Contains a collection of available appointment slots.
     */
    global class Result {
        @InvocableVariable(label='Appointment Slots')
        global AppointmentSlot[] slots = new List<AppointmentSlot>();
    }
}
