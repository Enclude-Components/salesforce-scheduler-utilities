/**
 * @description Invocable action that returns the Work Type record for a given
 *              Service Territory and Work Type Group combination
 *
 * @author      Brandon DeMatteis, Enclude
 * @since       09/04/2026
 * @group       Services
 */
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class GetWorkTypeForTerritory {

    global class Input {
        @InvocableVariable(required=true label='Service Territory ID')
        global String serviceTerritoryId;

        @InvocableVariable(required=true label='Work Type Group ID')
        global String workTypeGroupId;
    }

    global class Output {
        @InvocableVariable(label='Work Type')
        global WorkType workType;
    }

    @InvocableMethod(
        label='Get Work Type for Territory'
        description='Returns the Work Type record for a given Service Territory and Work Type Group'
        iconName='slds:standard:work_type'
    )
    global static Output[] getWorkType(Input[] inputs) {
        Output out = new Output();

        if (inputs == null || inputs.size() == 0) {
            return new Output[]{ out };
        }
        if (inputs.size() > 1) {
            throw new IllegalArgumentException('This action supports a single input only.');
        }

        Input params = inputs[0];

        List<WorkType> results = [
            SELECT FIELDS(STANDARD)
            FROM WorkType
            WHERE Id IN (
                SELECT WorkTypeId
                FROM ServiceTerritoryWorkType
                WHERE ServiceTerritoryId = :params.serviceTerritoryId
            )
            AND Id IN (
                SELECT WorkTypeId
                FROM WorkTypeGroupMember
                WHERE WorkTypeGroupId = :params.workTypeGroupId
            )
            WITH USER_MODE
            LIMIT 1
        ];

        if (!results.isEmpty()) {
            out.workType = results[0];
        }

        return new Output[]{ out };
    }
}