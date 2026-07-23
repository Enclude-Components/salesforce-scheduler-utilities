/**
 * @description Invocable action that returns active service resources (Technicians and Assets)
 *              for a given territory and work type group
 *
 * @author      Brandon DeMatteis, Enclude
 * @since       01/2026
 * @group       Services
 */
public with sharing class GetTerritoryServiceResources {
    private static final Set<String> RESOURCE_TYPES = new Set<String>{ 'T', 'S' };

    public class Input {
        @InvocableVariable(required=true label='Service Territory ID')
        public String serviceTerritoryId;

        @InvocableVariable(required=true label='Work Type Group ID')
        public String workTypeGroupId;
    }

    public class Output {
        @InvocableVariable
        public ServiceResource[] userResources = new ServiceResource[]{};

        @InvocableVariable
        public ServiceResource[] assetResources = new ServiceResource[]{};
    }

    /**
     * @description Returns active service resources for a territory, filtered by work type group shifts
     * @param inputs List containing a single Input with serviceTerritoryId and workTypeGroupId
     * @return List containing a single Output with resources
     */
    @InvocableMethod(
        label='Get Service Resources for Territory'
        description='Returns active service resources for a given territory'
    )
    public static Output[] getResources(Input[] inputs) {
        Output out = new Output();

        if (inputs == null || inputs.size() == 0) {
            return new Output[]{ out };
        }
        if (inputs.size() > 1) {
            throw new IllegalArgumentException('This action supports a single input only.');
        }

        Input params = inputs[0];

        List<ServiceResource> results = [
            SELECT FIELDS(STANDARD)
            FROM ServiceResource
            WHERE IsActive = true
            AND ResourceType IN :RESOURCE_TYPES
            AND Id IN (
                SELECT ServiceResourceId
                FROM ServiceTerritoryMember
                WHERE ServiceTerritoryId = :params.serviceTerritoryId
                AND EffectiveStartDate <= TODAY
                AND (EffectiveEndDate = NULL OR EffectiveEndDate >= TODAY)
            )
            AND Id IN (
                SELECT ServiceResourceId
                FROM Shift
                WHERE WorkTypeGroupId = :params.workTypeGroupId
            )
            WITH USER_MODE
            ORDER BY Name
            LIMIT 200
        ];

        for (ServiceResource sr : results) {
            if (sr.ResourceType == 'T') {
                out.userResources.add(sr);
            } else {
                out.assetResources.add(sr);
            }
        }

        return new Output[]{ out };
    }
}
