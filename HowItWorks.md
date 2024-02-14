# Order Routing Setup

### Prerequisite 
- Maarg instance should have write access to co.hotwax.order.routing.* entities 
- moqui.service.message.SystemMessageRemote.remotePublicKey record should exists with systemMessageRemoteId="HC_OMS_CONFIG"

``<moqui.service.message.SystemMessageRemote systemMessageRemoteId="HC_OMS_CONFIG" description="HotWax OMS server JWT token" remotePublicKey="<OMS JWT token>"/>``

### Order Routing Group
- Product store id requried to setup order routing group
- User can schedule Order Routing Group, ServiceJob will be scheduled for the routing group, and associate the jobName with OrderRoutingGroup
- ServiceJob will be executed as per ServerTime zone

### Order Routing

#### Order Filter Condition

#### Order Routing Rule

##### Order Routing Rule Inventory condition

#### Order Routing Rule Actions

