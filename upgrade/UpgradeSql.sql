update order_routing_rule set status_id="RULE_ACTIVE" where status_id="ORR_ACTIVE"
update order_routing_rule set status_id="RULE_DRAFT" where status_id="ORR_DRAFT"
update Order_Routing_Rule_Action set action_Type_Enum_Id="ORA_RM_CANCEL_DATE" where action_Type_Enum_Id ="ORA_AUTO_CANCEL_DATE"
update Order_Routing_Rule_Action set action_Type_Enum_Id = null where action_Type_Enum_Id ="ORA_BROKER"