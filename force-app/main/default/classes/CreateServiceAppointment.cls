/**
 * @description Invocable action that creates a Service Appointment and its
 *              associated Assigned Resource records
 *
 * @author      Brandon DeMatteis, Enclude
 * @since       01/2026
 * @group       Services
 */
public with sharing class CreateServiceAppointment {

    public class Input {
        @InvocableVariable(required=true label='Service Appointment')
        public ServiceAppointment serviceAppointment;

        @InvocableVariable(required=true label='Primary Resource')
        public ServiceResource primaryResource;

        @InvocableVariable(label='Required Resources')
        public ServiceResource[] requiredResources;
    }

    public class Output {
        @InvocableVariable
        public Id serviceAppointmentId;
    }

    /**
     * @description Creates a ServiceAppointment and AssignedResource records for the provided resources
     * @param inputs List containing a single Input
     * @return List containing a single Output with the created ServiceAppointment Id
     */
    @InvocableMethod(
        label='Create Service Appointment'
        description='Creates a Service Appointment and assigns service resources to it'
    )
    public static Output[] createAppointment(Input[] inputs) {
        if (inputs == null || inputs.size() != 1) {
            throw new IllegalArgumentException('This action supports a single input only.');
        }

        Input params = inputs[0];

        insert as user params.serviceAppointment;

        List<AssignedResource> assignedResources = new List<AssignedResource>();

        assignedResources.add(new AssignedResource(
            ServiceAppointmentId = params.serviceAppointment.Id,
            ServiceResourceId = params.primaryResource.Id,
            IsRequiredResource = true,
            IsPrimaryResource = true
        ));

        if (params.requiredResources != null) {
            for (ServiceResource resource : params.requiredResources) {
                assignedResources.add(new AssignedResource(
                    ServiceAppointmentId = params.serviceAppointment.Id,
                    ServiceResourceId = resource.Id,
                    IsRequiredResource = true
                ));
            }
        }

        insert as user assignedResources;

        Output out = new Output();
        out.serviceAppointmentId = params.serviceAppointment.Id;

        return new Output[]{ out };
    }
}
