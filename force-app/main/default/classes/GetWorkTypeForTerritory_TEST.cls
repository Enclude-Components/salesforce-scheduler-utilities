/**
 * @description Tests GetWorkTypeForTerritory.cls
 *
 * @author      Brandon DeMatteis, Enclude
 * @since       16/07/2026
 * @group       Tests
 */
@SuppressWarnings('PMD.MethodNamingConventions')
@IsTest
private class GetWorkTypeForTerritory_TEST {

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
     * @description A territory and group linked to the same work type should return that work type
     */
    @IsTest
    static void getWorkType_matchingTerritoryAndGroup_returnsWorkType() {
        ServiceTerritory territory = [SELECT Id FROM ServiceTerritory WHERE Name = 'Test Territory' LIMIT 1];
        WorkTypeGroup wtg = [SELECT Id FROM WorkTypeGroup WHERE Name = 'Test Work Type Group' LIMIT 1];
        WorkType workType = [SELECT Id FROM WorkType WHERE Name = 'Test Work Type' LIMIT 1];

        GetWorkTypeForTerritory.Input inp = new GetWorkTypeForTerritory.Input();
        inp.serviceTerritoryId = territory.Id;
        inp.workTypeGroupId = wtg.Id;

        Test.startTest();
        GetWorkTypeForTerritory.Output[] results = GetWorkTypeForTerritory.getWorkType(
            new GetWorkTypeForTerritory.Input[]{ inp }
        );
        Test.stopTest();

        Assert.areEqual(1, results.size(), 'Should return one output');
        Assert.isNotNull(results[0].workType, 'Should find the work type');
        Assert.areEqual(workType.Id, results[0].workType.Id, 'Should return the linked work type');
    }

    /**
     * @description A group with no member work types should return a null work type
     */
    @IsTest
    static void getWorkType_noMatch_returnsNullWorkType() {
        ServiceTerritory territory = [SELECT Id FROM ServiceTerritory WHERE Name = 'Test Territory' LIMIT 1];
        WorkTypeGroup emptyGroup = new WorkTypeGroup(Name = 'Empty Group', IsActive = true);
        insert emptyGroup;

        GetWorkTypeForTerritory.Input inp = new GetWorkTypeForTerritory.Input();
        inp.serviceTerritoryId = territory.Id;
        inp.workTypeGroupId = emptyGroup.Id;

        Test.startTest();
        GetWorkTypeForTerritory.Output[] results = GetWorkTypeForTerritory.getWorkType(
            new GetWorkTypeForTerritory.Input[]{ inp }
        );
        Test.stopTest();

        Assert.areEqual(1, results.size(), 'Should return one output');
        Assert.isNull(results[0].workType, 'Should return no work type when the group has no members');
    }

    /**
     * @description Null input should return a single empty output
     */
    @IsTest
    static void getWorkType_nullInput_returnsEmptyOutput() {
        Test.startTest();
        GetWorkTypeForTerritory.Output[] results = GetWorkTypeForTerritory.getWorkType(null);
        Test.stopTest();

        Assert.areEqual(1, results.size(), 'Should return one output');
        Assert.isNull(results[0].workType, 'Should return no work type for null input');
    }

    /**
     * @description Multiple inputs should throw an IllegalArgumentException
     */
    @IsTest
    static void getWorkType_multipleInputs_throws() {
        GetWorkTypeForTerritory.Input inp1 = new GetWorkTypeForTerritory.Input();
        GetWorkTypeForTerritory.Input inp2 = new GetWorkTypeForTerritory.Input();

        Test.startTest();
        try {
            GetWorkTypeForTerritory.getWorkType(
                new GetWorkTypeForTerritory.Input[]{ inp1, inp2 }
            );
            Assert.fail('Should have thrown');
        } catch (IllegalArgumentException e) {
            Assert.isTrue(e.getMessage().contains('single input'), 'Expected single input error');
        }
        Test.stopTest();
    }
}
