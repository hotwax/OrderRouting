<#macro buildSqlCondition fieldName filterCodnition>
  ${fieldName} ${Static["co.hotwax.order.routing.OrderRoutingHelper"].makeSqlWhere(filterCodnition)!}
</#macro>
SELECT
  ORDER_ID,
  SHIP_GROUP_SEQ_ID
  <#if selectOrderItemSeqId>,ORDER_ITEM_SEQ_ID <#--conditional field to select --></#if>
from
  (SELECT
    OH.ORDER_ID,
    OIS.SHIP_GROUP_SEQ_ID,
    OI.ORDER_ITEM_SEQ_ID,
    OH.PRODUCT_STORE_ID,
    OH.STATUS_ID,
    OH.ORDER_TYPE_ID,
    OI.STATUS_ID AS ITEM_STATUS_ID,
    FACTYPE.PARENT_TYPE_ID AS FACILITY_PARENT_TYPE_ID,
    OH.SALES_CHANNEL_ENUM_ID AS salesChannelEnumId,
    OI.PROMISED_DATETIME AS promisedDatetime,
    OIS.FACILITY_ID AS facilityId,
    OIS.SHIPMENT_METHOD_TYPE_ID as shipmentMethodTypeId,
    OH.PRIORITY as priority,
    OIS.SHIP_AFTER_DATE AS shipAfterDate,
    OH.ORDER_DATE AS orderDate,
    CSM.DELIVERY_DAYS AS deliveryDays
  FROM
    ORDER_HEADER OH
    INNER JOIN ORDER_ITEM_SHIP_GROUP OIS ON OH.ORDER_ID = OIS.ORDER_ID
    INNER JOIN ORDER_ITEM OI ON OIS.ORDER_ID = OI.ORDER_ID AND OIS.SHIP_GROUP_SEQ_ID = OI.SHIP_GROUP_SEQ_ID
    <#if productCategoryCondition?has_content>INNER JOIN PRODUCT_CATEGORY_MEMBER PCM ON PCM.PRODUCT_ID=OI.PRODUCT_ID AND <@buildSqlCondition 'PCM.PRODUCT_CATEGORY_ID' productCategoryCondition/> <#-- buildSqlCondition--></#if>
    <#if facilityGroupCondition?has_content>INNER JOIN FACILITY_GROUP_MEMBER FGM ON FGM.FACILITY_ID=OH.ORIGIN_FACILITY_ID AND <@buildSqlCondition 'FGM.FACILITY_GROUP_ID' facilityGroupCondition/> <#-- buildSqlCondition--></#if>
    LEFT OUTER JOIN CARRIER_SHIPMENT_METHOD CSM ON OIS.SHIPMENT_METHOD_TYPE_ID = CSM.SHIPMENT_METHOD_TYPE_ID AND OIS.CARRIER_PARTY_ID = CSM.PARTY_ID AND OIS.CARRIER_ROLE_TYPE_ID = CSM.ROLE_TYPE_ID
    LEFT OUTER JOIN FACILITY FAC ON OIS.FACILITY_ID = FAC.FACILITY_ID
    LEFT OUTER JOIN FACILITY_TYPE FACTYPE ON FAC.FACILITY_TYPE_ID = FACTYPE.FACILITY_TYPE_ID) as ORD
WHERE
  (
    PRODUCT_STORE_ID = '${productStoreId!''}'
    AND STATUS_ID = '${orderStatusId!''}'
    AND ORDER_TYPE_ID = '${orderTypeId!''}'
    AND ITEM_STATUS_ID = '${itemStatusId!''}'
    AND FACILITY_PARENT_TYPE_ID = '${facilityParentTypeId!''}'
    <#if orderId?has_content>
      AND ORDER_ID= '${orderId}'
      <#if shipGroupSeqId?has_content> AND SHIP_GROUP_SEQ_ID = ${shipGroupSeqId}</#if>
    </#if>
    <#if orderFilterConditions?has_content>
      <#list orderFilterConditions as filterCondition>
        AND <@buildSqlCondition filterCondition.fieldName filterCondition/>
      </#list>
    </#if>
  )
GROUP BY
  ORDER_ID,
  SHIP_GROUP_SEQ_ID
  <#if selectOrderItemSeqId>, ORDER_ITEM_SEQ_ID</#if> <#-- If items are filtered using promisedDatetime, we need to include orderItemSeqId in the GROUP BY clause -->
HAVING
  COUNT(ORDER_ITEM_SEQ_ID) > '0'
ORDER BY
  <#if orderSortByList?has_content>
    <#list orderSortByList as orderSortBy>
      ${orderSortBy!}<#sep>,
    </#list>
  <#else>
    orderDate ASC
  </#if>