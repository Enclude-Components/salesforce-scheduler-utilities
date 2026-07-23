/**
 * @description Invocable action that returns Service Territories associated with a given Work Type Group
 *
 * @author      Brandon DeMatteis, Enclude
 * @since       09/04/2026
 * @group       Services
 */
public with sharing class GetWorkTypeGroupTerritories {

    public class Input {
        @InvocableVariable(required=true label='Work Type Group ID')
        public String workTypeGroupId;
    }

    public class Output {
        @InvocableVariable
        public ServiceTerritory[] territories = new ServiceTerritory[]{};
    }

    /**
     * @description Returns distinct Service Territories linked to a Work Type Group via WorkTypeGroupMember
     * @param inputs List containing a single Input with workTypeGroupId
     * @return List containing a single Output with territories
     */
    @InvocableMethod(
        label='Get Service Territories for Work Type Group'
        description='Returns distinct Service Territories associated with a given Work Type Group'
        iconName='slds:standard:location'
    )
    public static Output[] getTerritories(Input[] inputs) {
        Output out = new Output();

        if (inputs == null || inputs.size() == 0) {
            return new Output[]{ out };
        }
        if (inputs.size() > 1) {
            throw new IllegalArgumentException('This action supports a single input only.');
        }

        String workTypeGroupId = inputs[0].workTypeGroupId;

        List<Id> workTypeIds = new List<Id>();
        for (WorkTypeGroupMember m : [
            SELECT WorkTypeId
            FROM WorkTypeGroupMember
            WHERE WorkTypeGroupId = :workTypeGroupId
            WITH USER_MODE
        ]) {
            workTypeIds.add(m.WorkTypeId);
        }

        String fieldNames = String.join(
            new List<String>(Schema.SObjectType.ServiceTerritory.fields.getMap().keySet()),
            ', '
        );

        out.territories = Database.query(
            'SELECT ' + fieldNames + ' ' +
            'FROM ServiceTerritory ' +
            'WHERE Id IN (' +
            '    SELECT ServiceTerritoryId ' +
            '    FROM ServiceTerritoryWorkType ' +
            '    WHERE WorkTypeId IN :workTypeIds' +
            ') ' +
            'WITH USER_MODE ' +
            'ORDER BY Name ' +
            'LIMIT 200'
        );
        return new Output[]{ out };
    }
}
