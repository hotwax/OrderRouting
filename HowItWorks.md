# Order Routing Setup

## Prerequisite  


```bash
    <moqui.service.message.SystemMessageRemote systemMessageRemoteId="HC_OMS_CONFIG" sendUrl=""
            description="HotWax OMS server JWT token" remotePublicKey="<OMS JWT token>"/>
```

## Order Routing Group
- Product store id requried to setup order routing group
- User can schedule Order Routing Group, ServiceJob will be scheduled for the routing group, and associate the jobName with OrderRoutingGroup
- ServiceJob will be executed as per ServerTime zone

### Order Routing

#### Order Filter Condition
- Queue (facilityId)
- Shipment method type (shipmentMethodTypeId)
- Order Priority (priority)
- Promise Date (promiseDaysCutoff)
- Sales channel (salesChannelEnumId)
- Origin facility group (originFacilityGroupId)
- Product category (productCategoryId)

#### Sort By
- Ship by (shipBeforeDate)
- Ship after (shipAfterDate)
- Order date (orderDate)
- Shipping method (deliveryDays)
- Order priority (priority)

### Order Routing Rule

#### Assignment type
- Single 
- Partial assignment

#### Rule Inventory condition
##### Filter Condition
 - Facility group (facilityGroupId)
 - Proximity (distance)
 - Systems of measurement (measurementSystem)
 - Brokering safety stock (brokeringSafetyStock)
 - Split order item group (splitOrderItemGroup)
 - Override facility order limit (ignoreFacilityOrderLimit)
 - Shipment threshold value check (shipmentThreshold)
 - All items available anywhere (brokerIfAllItemsAvailable)

##### Sort By
- Proximity (distance)
- Inventory balance (inventoryForAllocation)
- Custom sequence (facilitySequence)

#### Rule Actions
##### Rule Action type
- Add auto-cancel days
- Clear auto-cancel date
- Move to next Rule (default)
- Move to queue


## Comparison Operator
- less
- greater
- less-equals
- greater-equals
- equals
- not-equals
- in
- not-in
- is-null
- is-not-null

## Measurement System type
- Imperial system (default)
- Metric system

