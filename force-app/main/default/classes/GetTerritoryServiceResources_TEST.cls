/**
 * @description Test class for GetTerritoryServiceResources, SerializeServiceResources,
 *              and CreateServiceAppointment
 *
 * @author      Brandon DeMatteis, Enclude
 * @since       01/2026
 * @group       Tests
 */
@IsTest
private class GetTerritoryServiceResources_TEST {

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

        WorkTypeGroup wtg = new WorkTypeGroup(
            Name = 'Test Work Type Group',
            IsActive = true
        );
        insert wtg;

        ServiceResource techResource = new ServiceResource(
            Name = 'Test Technician',
            ResourceType = 'T',
            IsActive = true,
            RelatedRecordId = UserInfo.getUserId()
        );
        insert techResource;

        Account acc = new Account(Name = 'Test Account');
        insert acc;

        Asset testAsset = new Asset(Name = 'Test Asset', AccountId = acc.Id);
        insert testAsset;

        ServiceResource assetResource = new ServiceResource(
            Name = 'Test Asset Resource',
            ResourceType = 'S',
            IsActive = true,
            AssetId = testAsset.Id
        );
        insert assetResource;

        insert new List<ServiceTerritoryMember>{
            new ServiceTerritoryMember(
                ServiceTerritoryId = territory.Id,
                ServiceResourceId = techResource.Id,
                EffectiveStartDate = Date.today().addDays(-1),
                EffectiveEndDate = Date.today().addDays(30)
            ),
            new ServiceTerritoryMember(
                ServiceTerritoryId = territory.Id,
                ServiceResourceId = assetResource.Id,
                EffectiveStartDate = Date.today().addDays(-1),
                EffectiveEndDate = Date.today().addDays(30)
            )
        };

        insert new List<Shift>{
            new Shift(
                ServiceResourceId = techResource.Id,
                WorkTypeGroupId = wtg.Id,
                StartTime = DateTime.now(),
                EndTime = DateTime.now().addHours(8)
            ),
            new Shift(
                ServiceResourceId = assetResource.Id,
                WorkTypeGroupId = wtg.Id,
                StartTime = DateTime.now(),
                EndTime = DateTime.now().addHours(8)
            )
        };
    }

    @IsTest
    static void testGetResources() {
        ServiceTerritory territory = [SELECT Id FROM ServiceTerritory WHERE Name = 'Test Territory' LIMIT 1];
        WorkTypeGroup wtg = [SELECT Id FROM WorkTypeGroup WHERE Name = 'Test Work Type Group' LIMIT 1];

        GetTerritoryServiceResources.Input inp = new GetTerritoryServiceResources.Input();
        inp.serviceTerritoryId = territory.Id;
        inp.workTypeGroupId = wtg.Id;

        Test.startTest();
        GetTerritoryServiceResources.Output[] results = GetTerritoryServiceResources.getResources(
            new GetTerritoryServiceResources.Input[]{ inp }
        );
        Test.stopTest();

        System.assertEquals(1, results.size(), 'Should return one output');
        GetTerritoryServiceResources.Output out = results[0];
        System.assertEquals(1, out.userResources.size(), 'Should have one technician');
        System.assertEquals(1, out.assetResources.size(), 'Should have one asset');

        ServiceResource tech = out.userResources[0];
        System.assertEquals('Test Technician', tech.Name);
        System.assertEquals('T', tech.ResourceType);

        ServiceResource asset = out.assetResources[0];
        System.assertEquals('Test Asset Resource', asset.Name);
        System.assertEquals('S', asset.ResourceType);
    }

    @IsTest
    static void testNullInput() {
        Test.startTest();
        GetTerritoryServiceResources.Output[] results = GetTerritoryServiceResources.getResources(null);
        Test.stopTest();

        System.assertEquals(1, results.size(), 'Should return empty output');
        System.assertEquals(0, results[0].userResources.size(), 'Should have no technicians');
        System.assertEquals(0, results[0].assetResources.size(), 'Should have no assets');
    }

    @IsTest
    static void testMultipleInputsThrows() {
        GetTerritoryServiceResources.Input inp1 = new GetTerritoryServiceResources.Input();
        inp1.serviceTerritoryId = 'fake1';
        inp1.workTypeGroupId = 'fake1';

        GetTerritoryServiceResources.Input inp2 = new GetTerritoryServiceResources.Input();
        inp2.serviceTerritoryId = 'fake2';
        inp2.workTypeGroupId = 'fake2';

        try {
            GetTerritoryServiceResources.getResources(
                new GetTerritoryServiceResources.Input[]{ inp1, inp2 }
            );
            System.assert(false, 'Should have thrown');
        } catch (IllegalArgumentException e) {
            System.assert(e.getMessage().contains('single input'), 'Expected single input error');
        }
    }

    @IsTest
    static void testSerializeServiceResources() {
        ServiceResource techResource = [SELECT Id, Name, ResourceType, RelatedRecordId, IsActive FROM ServiceResource WHERE Name = 'Test Technician' LIMIT 1];
        ServiceResource assetResource = [SELECT Id, Name, ResourceType, RelatedRecordId, IsActive FROM ServiceResource WHERE Name = 'Test Asset Resource' LIMIT 1];

        SerializeServiceResources.Input inp = new SerializeServiceResources.Input();
        inp.primaryResource = techResource;
        inp.requiredResources = new ServiceResource[]{ assetResource };

        Test.startTest();
        SerializeServiceResources.Output[] results = SerializeServiceResources.serialize(
            new SerializeServiceResources.Input[]{ inp }
        );
        Test.stopTest();

        System.assertNotEquals(null, results[0].serializedResources, 'Should return serialized JSON');
        System.assert(results[0].serializedResources.contains('"AttendanceType":"Primary"'), 'Should contain Primary attendance');
        System.assert(results[0].serializedResources.contains('"AttendanceType":"Required"'), 'Should contain Required attendance');
    }

    @IsTest
    static void testCreateServiceAppointment() {
        ServiceTerritory territory = [SELECT Id FROM ServiceTerritory WHERE Name = 'Test Territory' LIMIT 1];
        ServiceResource techResource = [SELECT Id FROM ServiceResource WHERE Name = 'Test Technician' LIMIT 1];
        ServiceResource assetResource = [SELECT Id FROM ServiceResource WHERE Name = 'Test Asset Resource' LIMIT 1];

        ServiceAppointment sa = new ServiceAppointment(
            ServiceTerritoryId = territory.Id,
            SchedStartTime = DateTime.now().addDays(1),
            SchedEndTime = DateTime.now().addDays(1).addHours(1),
            ParentRecordId = [SELECT Id FROM Account LIMIT 1].Id
        );

        CreateServiceAppointment.Input inp = new CreateServiceAppointment.Input();
        inp.serviceAppointment = sa;
        inp.primaryResource = techResource;
        inp.requiredResources = new ServiceResource[]{ assetResource };

        Test.startTest();
        CreateServiceAppointment.Output[] results = CreateServiceAppointment.createAppointment(
            new CreateServiceAppointment.Input[]{ inp }
        );
        Test.stopTest();

        System.assertNotEquals(null, results[0].serviceAppointmentId, 'Should return the SA Id');

        List<AssignedResource> ars = [
            SELECT ServiceResourceId
            FROM AssignedResource
            WHERE ServiceAppointmentId = :results[0].serviceAppointmentId
        ];
        System.assertEquals(2, ars.size(), 'Should have two assigned resources');
    }
}
