/**
 * @description Tests GetWorkTypeGroupTerritories.cls
 *
 * @author      Brandon DeMatteis, Enclude
 * @since       16/07/2026
 * @group       Tests
 */
@SuppressWarnings('PMD.MethodNamingConventions')
@IsTest
private class GetWorkTypeGroupTerritories_TEST {

    @TestSetup
    static void setupData() {
        OperatingHours oh = new OperatingHours(Name = 'Test Hours');
        insert oh;

        ServiceTerritory territory = new ServiceTerritory(
            Name = 'Test Territory',
            OperatingHoursId = oh.Id,
            IsActive = true
        );
        insert territory;

        WorkType workType = new WorkType(
            Name = 'Test Work Type',
            EstimatedDuration = 60,
            DurationType = 'Minutes'
        );
        insert workType;

        WorkTypeGroup wtg = new WorkTypeGroup(
            Name = 'Test Work Type Group',
            IsActive = true
        );
        insert wtg;

        insert new WorkTypeGroupMember(
            WorkTypeGroupId = wtg.Id,
            WorkTypeId = workType.Id
        );

        insert new ServiceTerritoryWorkType(
            ServiceTerritoryId = territory.Id,
            WorkTypeId = workType.Id
        );
    }

    /**
     * @description A group whose work type is linked to a territory should return that territory
     */
    @IsTest
    static void getTerritories_linkedTerritory_returnsTerritory() {
        ServiceTerritory territory = [SELECT Id FROM ServiceTerritory WHERE Name = 'Test Territory' LIMIT 1];
        WorkTypeGroup wtg = [SELECT Id FROM WorkTypeGroup WHERE Name = 'Test Work Type Group' LIMIT 1];

        GetWorkTypeGroupTerritories.Input inp = new GetWorkTypeGroupTerritories.Input();
        inp.workTypeGroupId = wtg.Id;

        Test.startTest();
        GetWorkTypeGroupTerritories.Output[] results = GetWorkTypeGroupTerritories.getTerritories(
            new GetWorkTypeGroupTerritories.Input[]{ inp }
        );
        Test.stopTest();

        Assert.areEqual(1, results.size(), 'Should return one output');
        Assert.areEqual(1, results[0].territories.size(), 'Should return one territory');
        Assert.areEqual(territory.Id, results[0].territories[0].Id, 'Should return the linked territory');
    }

    /**
     * @description A group with no member work types should return no territories
     */
    @IsTest
    static void getTerritories_groupWithoutMembers_returnsNoTerritories() {
        WorkTypeGroup emptyGroup = new WorkTypeGroup(Name = 'Empty Group', IsActive = true);
        insert emptyGroup;

        GetWorkTypeGroupTerritories.Input inp = new GetWorkTypeGroupTerritories.Input();
        inp.workTypeGroupId = emptyGroup.Id;

        Test.startTest();
        GetWorkTypeGroupTerritories.Output[] results = GetWorkTypeGroupTerritories.getTerritories(
            new GetWorkTypeGroupTerritories.Input[]{ inp }
        );
        Test.stopTest();

        Assert.areEqual(1, results.size(), 'Should return one output');
        Assert.areEqual(0, results[0].territories.size(), 'Should return no territories when the group has no members');
    }

    /**
     * @description Null input should return a single empty output
     */
    @IsTest
    static void getTerritories_nullInput_returnsEmptyOutput() {
        Test.startTest();
        GetWorkTypeGroupTerritories.Output[] results = GetWorkTypeGroupTerritories.getTerritories(null);
        Test.stopTest();

        Assert.areEqual(1, results.size(), 'Should return one output');
        Assert.areEqual(0, results[0].territories.size(), 'Should return no territories for null input');
    }

    /**
     * @description Multiple inputs should throw an IllegalArgumentException
     */
    @IsTest
    static void getTerritories_multipleInputs_throws() {
        GetWorkTypeGroupTerritories.Input inp1 = new GetWorkTypeGroupTerritories.Input();
        GetWorkTypeGroupTerritories.Input inp2 = new GetWorkTypeGroupTerritories.Input();

        Test.startTest();
        try {
            GetWorkTypeGroupTerritories.getTerritories(
                new GetWorkTypeGroupTerritories.Input[]{ inp1, inp2 }
            );
            Assert.fail('Should have thrown');
        } catch (IllegalArgumentException e) {
            Assert.isTrue(e.getMessage().contains('single input'), 'Expected single input error');
        }
        Test.stopTest();
    }
}
