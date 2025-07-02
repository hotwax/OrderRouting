# How Order Routing Works

This document explains the end-to-end flow of how order routing is executed in the HotWax Commerce platform using the `OrderRouting` component.

---

## Overview

Order routing is the process of evaluating open customer orders, grouping them based on configured rules, and brokering them to optimal fulfillment locations (e.g., warehouses or stores). The goal is to minimize split shipments, reduce shipping costs, and improve fulfillment efficiency.

---

## Components Involved

1. **Order Routing Group**  
   A group of one or more order routings. Each routing group is tied to a product store and can be scheduled using a Moqui ServiceJob.

2. **Order Routing**  
   Represents a single routing definition composed of filter conditions and routing rules. This is the logical unit responsible for selecting which orders to route and how.

3. **Routing Rule**  
   Contains one or more inventory rules and associated rule actions. These define how fulfillment facilities are selected and what actions are triggered based on routing logic.

4. **Inventory Rule**  
   Controls how and where inventory is evaluated during routing. It determines if a fulfillment location qualifies based on available inventory, split logic, or inventory thresholds.

5. **Order Routing Batch**  
   A batch represents a single execution run of the routing group, either manual or scheduled. It processes a set of eligible unbrokered orders.

---

## Order Routing Group

- A **Product Store ID** is required to configure an Order Routing Group. This associates the group with a specific store and its rules.
- Users can schedule an Order Routing Group by linking it to a **ServiceJob**, which is a scheduled Moqui job.
- Each routing group maintains an associated job name used for scheduling and logging.
- The **ServiceJob** is executed based on the **server's time zone**, which is crucial for ensuring timely routing.
- A semaphore is configured per product store to ensure that only one brokering job runs at a time per product store, preventing concurrent conflicts and ensuring consistency in routing logic.

---

## Order Filter Condition

Routing filters are used to narrow down the pool of eligible orders before evaluating routing rules. The routing engine selects the order item ship-groups that meet the filter criteria and then applies routing logic on those selected ship-group items. Filters include:

- **Queue (`facilityId`)** – Restricts routing to orders intended for a specific facility.
- **Shipment Method Type (`shipmentMethodTypeId`)** – Filters orders based on delivery type (e.g., Standard, Second Day, Next Day).
- **Order Priority (`priority`)** – Targets urgent or VIP orders for prioritized routing.
- **Promise Date (`promiseDaysCutoff`)** – Evaluates order items against a promise-by date. If this filter is selected, the routing engine processes one order item at a time based on the cutoff date. This allows more granular control, ensuring high-priority or time-sensitive items are brokered independently and efficiently.
- **Sales Channel (`salesChannelEnumId`)** – Filters orders by origin, such as Web , Facebook or POS.
- **Origin Facility Group (`originFacilityGroupId`)** – Limits orders to those from a specific set of source facilities.
- **Product Category (`productCategoryId`)** – Filters order ship groups containing products in a specific category.

### Sort By Options

These determine the order in which filtered orders are processed:

- **Ship By Date (`shipBeforeDate`)** – Prioritize orders needing shipment by a specific date.
- **Ship After Date (`shipAfterDate`)** – Orders not to be shipped before this date.
- **Order Date (`orderDate`)** – Older orders can be prioritized.
- **Shipping Method (`deliveryDays`)** – Orders are prioritized based on delivery urgency. Shorter delivery windows (e.g., next-day delivery) are handled first to meet customer expectations. The value is configured using `CarrierShipmentMethod.deliveryDays`. This ensures that time-sensitive orders are brokered before standard or multi-day shipping orders.
- **Order Priority (`priority`)** – Orders are sorted by configured urgency.

---

## Order Routing Rule

Routing Rules are used to evaluate and assign fulfillment options based on custom logic and filters.

### Assignment Type

- **Single** – Order must be fulfilled from a single facility.
- **Partial Assignment** – Items may be split across multiple facilities if needed.

### Rule Inventory Condition – Filter Conditions

- **Facility Group (`facilityGroupId`)** – Only consider facilities in this group.
- **Proximity (`distance`)** – Evaluate based on distance to shipping address.
- **System of Measurement (`measurementSystem`)** – Distance calculation uses Metric or Imperial.
- **Brokering Safety Stock (`brokeringSafetyStock`)** – Adjust available inventory by subtracting a buffer.
- **Split Order Item Group (`splitOrderItemGroup`)** – Allow splitting of item groups when routing.
- **Override Facility Order Limit (`ignoreFacilityOrderLimit`)** – Bypass facility’s capacity constraints.
- **Shipment Threshold Value Check (`shipmentThreshold`)** – Minimum shipment value required for routing.
- **All Items Available Anywhere (`brokerIfAllItemsAvailable`)** – Only proceed if all items are available in one or more locations.

### Sort By Options

- **Proximity (`distance`)** – Closest facility is preferred.
- **Inventory Balance (`inventoryForAllocation`)** – Facilities with more available inventory are prioritized.
- **Custom Sequence (`facilitySequence`)** – Facilities sorted based on predefined ranking.

---

## Rule Actions

Routing rules can include actions based on evaluated conditions.

### Rule Action Type

- **Add Auto-Cancel Days** – Adds a cancellation window to the order item if not brokered.
- **Clear Auto-Cancel Date** – Removes any existing auto-cancel date from order item.
- **Move to Next Rule** – Proceeds to the next rule in the sequence (default behavior).
- **Move to Queue** – Reassigns the order to a specific queue.

### Comparison Operators

Used to evaluate conditional logic within rules:

- **less** / **greater** – Basic numeric comparison.
- **less-equals** / **greater-equals** – Inclusive numeric comparison.
- **equals** / **not-equals** – Check for value matches.
- **in** / **not-in** – Set-based membership.
- **is-null** / **is-not-null** – Checks if field has a value.

### Measurement System Type

- **Imperial System** – Uses miles/pounds; default setting.
- **Metric System** – Uses kilometers/kilograms.

---

## Scheduled Routing

Routing batches can be triggered periodically via scheduler configuration.
This ensures routing continues automatically without manual intervention.
