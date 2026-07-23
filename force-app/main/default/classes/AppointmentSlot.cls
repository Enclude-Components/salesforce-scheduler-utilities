/**
 * @description Apex-defined type representing a single available appointment slot
 *              as returned by the Lightning Scheduler getAppointmentSlots API.
 *
 * @author      Brandon DeMatteis, Enclude
 * @since       24/03/2026
 * @group       Scheduling
 */
@SuppressWarnings('PMD.AvoidGlobalModifier')
global class AppointmentSlot {
    @AuraEnabled @InvocableVariable(label='Start Time')
    global Datetime startTime;

    @AuraEnabled @InvocableVariable(label='End Time')
    global Datetime endTime;

    @AuraEnabled @InvocableVariable(label='Territory ID')
    global String territoryId;

    @AuraEnabled @InvocableVariable(label='Remaining Appointments')
    global Integer remainingAppointments;

    /**
     * @description Deserializes the JSON response from getAppointmentSlots into a list of AppointmentSlot records.
     * @param response JSON string returned by lxscheduler.SchedulerResources.getAppointmentSlots
     * @return List of AppointmentSlot records
     */
    public static AppointmentSlot[] fromGetAppointmentSlotsResponse(String response) {
        AppointmentSlot[] slots = new AppointmentSlot[]{};
        for (Object item : (List<Object>) JSON.deserializeUntyped(response)) {
            Map<String, Object> row = (Map<String, Object>) item;
            AppointmentSlot slot = new AppointmentSlot();
            slot.startTime             = parseDateTime((String) row.get('startTime'));
            slot.endTime               = parseDateTime((String) row.get('endTime'));
            slot.territoryId           = (String) row.get('territoryId');
            slot.remainingAppointments = (Integer) row.get('remainingAppointments');
            slots.add(slot);
        }
        return slots;
    }

    private static Datetime parseDateTime(String isoString) {
        if (isoString == null) return null;
        return (Datetime) JSON.deserialize('"' + isoString + '"', Datetime.class);
    }
}
