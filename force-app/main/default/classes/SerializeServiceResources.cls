/**
 * @description Invocable action that serializes service resources into the JSON format
 *              expected by the LWC Select Service Appointment Time component
 *
 * @author      Brandon DeMatteis, Enclude
 * @since       01/2026
 * @group       Services
 */
public with sharing class SerializeServiceResources {

    public class Input {
        @InvocableVariable(required=true label='Primary Resource')
        public ServiceResource primaryResource;

        @InvocableVariable(label='Required Resources')
        public ServiceResource[] requiredResources;
    }

    public class Output {
        @InvocableVariable
        public String serializedResources;
    }

    /**
     * @description Serializes a primary resource and optional required resources into a JSON string
     * @param inputs List containing a single Input with primaryResource and optional requiredResources
     * @return List containing a single Output with the serialized JSON string
     */
    @InvocableMethod(
        label='Serialize Service Resources'
        description='Serializes service resources into JSON for the appointment booking component'
    )
    public static Output[] serialize(Input[] inputs) {
        Input params = inputs[0];

        List<Map<String, Object>> allResources = new List<Map<String, Object>>();
        allResources.add(toResourceMap(params.primaryResource, 'Primary'));

        if (params.requiredResources != null) {
            for (ServiceResource sr : params.requiredResources) {
                allResources.add(toResourceMap(sr, 'Required'));
            }
        }

        Output out = new Output();
        out.serializedResources = JSON.serialize(allResources);
        return new Output[]{ out };
    }

    private static Map<String, Object> toResourceMap(ServiceResource sr, String attendanceType) {
        return new Map<String, Object>{
            'Id'             => sr.Id,
            'Name'           => sr.Name,
            'ResourceType'   => sr.ResourceType,
            'RelatedRecordId'=> sr.RelatedRecordId,
            'IsActive'       => sr.IsActive,
            'sobjectType'    => 'ServiceResource',
            'AttendanceType' => attendanceType
        };
    }
}
