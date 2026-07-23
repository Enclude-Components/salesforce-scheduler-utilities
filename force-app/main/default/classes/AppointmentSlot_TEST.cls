/**
 * @description Tests AppointmentSlot.cls
 * @author      Brandon DeMatteis, Enclude
 * @since       24/03/2026
 * @group       Tests
 */
@SuppressWarnings('PMD.MethodNamingConventions')
@IsTest
public class AppointmentSlot_TEST {

    /**
     * @description Single slot JSON should map all fields correctly
     */
    @IsTest
    static void fromGetAppointmentSlotsResponse_singleSlot_mapsAllFields() {
        String response = JSON.serialize(new List<Map<String, Object>>{
            new Map<String, Object>{
                'startTime'             => '2026-03-25T09:00:00.000Z',
                'endTime'               => '2026-03-25T10:00:00.000Z',
                'territoryId'           => 'ABC123',
                'remainingAppointments' => 5
            }
        });

        Test.startTest();
        AppointmentSlot[] slots = AppointmentSlot.fromGetAppointmentSlotsResponse(response);
        Test.stopTest();

        Assert.areEqual(1, slots.size(), 'Should return one slot');
        Assert.areEqual(Datetime.newInstanceGmt(2026, 3, 25, 9, 0, 0),  slots[0].startTime,             'startTime should be mapped correctly');
        Assert.areEqual(Datetime.newInstanceGmt(2026, 3, 25, 10, 0, 0), slots[0].endTime,               'endTime should be mapped correctly');
        Assert.areEqual('ABC123',                                         slots[0].territoryId,           'territoryId should be mapped correctly');
        Assert.areEqual(5,                                                slots[0].remainingAppointments, 'remainingAppointments should be mapped correctly');
    }

    /**
     * @description Multiple slots in the response should all be returned
     */
    @IsTest
    static void fromGetAppointmentSlotsResponse_multipleSlots_returnsAllSlots() {
        String response = JSON.serialize(new List<Map<String, Object>>{
            new Map<String, Object>{
                'startTime'             => '2026-03-25T09:00:00.000Z',
                'endTime'               => '2026-03-25T10:00:00.000Z',
                'territoryId'           => 'ABC123',
                'remainingAppointments' => 3
            },
            new Map<String, Object>{
                'startTime'             => '2026-03-25T11:00:00.000Z',
                'endTime'               => '2026-03-25T12:00:00.000Z',
                'territoryId'           => 'ABC123',
                'remainingAppointments' => 1
            },
            new Map<String, Object>{
                'startTime'             => '2026-03-25T14:00:00.000Z',
                'endTime'               => '2026-03-25T15:00:00.000Z',
                'territoryId'           => 'DEF456',
                'remainingAppointments' => 2
            }
        });

        Test.startTest();
        AppointmentSlot[] slots = AppointmentSlot.fromGetAppointmentSlotsResponse(response);
        Test.stopTest();

        Assert.areEqual(3, slots.size(), 'Should return all three slots');
    }

    /**
     * @description Empty array response should return an empty list
     */
    @IsTest
    static void fromGetAppointmentSlotsResponse_emptyArray_returnsEmptyList() {
        String response = '[]';

        Test.startTest();
        AppointmentSlot[] slots = AppointmentSlot.fromGetAppointmentSlotsResponse(response);
        Test.stopTest();

        Assert.areEqual(0, slots.size(), 'Should return an empty list');
    }

    /**
     * @description Null startTime and endTime values in the response should be handled gracefully
     */
    @IsTest
    static void fromGetAppointmentSlotsResponse_nullDateTimes_treatedAsNull() {
        String response = JSON.serialize(new List<Map<String, Object>>{
            new Map<String, Object>{
                'startTime'             => null,
                'endTime'               => null,
                'territoryId'           => 'ABC123',
                'remainingAppointments' => 2
            }
        });

        Test.startTest();
        AppointmentSlot[] slots = AppointmentSlot.fromGetAppointmentSlotsResponse(response);
        Test.stopTest();

        Assert.areEqual(1,       slots.size(),          'Should return one slot');
        Assert.areEqual(null,    slots[0].startTime,    'startTime should be null');
        Assert.areEqual(null,    slots[0].endTime,      'endTime should be null');
        Assert.areEqual('ABC123', slots[0].territoryId, 'territoryId should still be mapped');
    }
}
