package co.hotwax.order.routing;
import com.auth0.jwt.JWT;
import com.auth0.jwt.JWTCreator;
import com.auth0.jwt.algorithms.Algorithm;
import org.moqui.entity.EntityCondition;
import org.moqui.impl.context.ExecutionContextFactoryImpl;
import org.moqui.impl.entity.EntityConditionFactoryImpl;
import org.moqui.util.SystemBinding;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.moqui.entity.EntityValue;

import javax.cache.Cache;
import java.time.Instant;
import java.time.ZonedDateTime;
import java.util.Arrays;
import java.util.Collection;
import java.util.Iterator;
import java.util.Map;

public class OrderRoutingHelper {
    protected static final Logger logger = LoggerFactory.getLogger(OrderRoutingHelper.class);
    protected static Cache<String, String> jwtCache;
    public static String makeSqlWhere(EntityValue ev) {
        @SuppressWarnings("MismatchedQueryAndUpdateOfStringBuilder")
        StringBuilder sql = new StringBuilder();
        boolean valueDone = false;
        Object value = ev.get("fieldValue");
        EntityCondition.ComparisonOperator operator = EntityConditionFactoryImpl.getComparisonOperator(ev.getString("operator"));
        if (value == null) {
            if (operator == EntityCondition.EQUALS || operator == EntityCondition.LIKE || operator == EntityCondition.IN || operator == EntityCondition.BETWEEN) {
                sql.append(" IS NULL");
                valueDone = true;
            } else if (operator == EntityCondition.NOT_EQUAL || operator == EntityCondition.NOT_LIKE || operator == EntityCondition.NOT_IN || operator == EntityCondition.NOT_BETWEEN) {
                sql.append(" IS NOT NULL");
                valueDone = true;
            }
        }
        if (operator == EntityCondition.IS_NULL || operator == EntityCondition.IS_NOT_NULL) {
            sql.append(EntityConditionFactoryImpl.getComparisonOperatorString(operator));
            valueDone = true;
        }
        if (!valueDone) {
            // append operator
            sql.append(EntityConditionFactoryImpl.getComparisonOperatorString(operator));
            // for IN/BETWEEN change string to collection
            if (operator == EntityCondition.IN || operator == EntityCondition.NOT_IN || operator == EntityCondition.BETWEEN || operator == EntityCondition.NOT_BETWEEN)
                value = valueToCollection(value);
            if (operator == EntityCondition.IN || operator == EntityCondition.NOT_IN) {
                if (value instanceof Collection) {
                    sql.append(" (");
                    boolean isFirst = true;
                    for (Object curValue : (Collection) value) {
                        if (isFirst) isFirst = false; else sql.append(", ");
                        sql.append("'" + curValue + "'");
                    }
                    sql.append(')');
                } else {
                    sql.append(" ('" + value +"') ");
                }
            } else if ((operator == EntityCondition.BETWEEN || operator == EntityCondition.NOT_BETWEEN) && value instanceof Collection &&
                    ((Collection) value).size() == 2) {
                Iterator iterator = ((Collection) value).iterator();
                Object value1 = iterator.next();
                Object value2 = iterator.next();
                sql.append(" '" + value1 +"' AND '" + value2 + "'");
            } else {
                sql.append(" '" + value + "'");
            }
        }
        return sql.toString();
    }
    static Object valueToCollection(Object value) {
        if (value instanceof CharSequence) {
            String valueStr = value.toString();
            // note: used to do this, now always put in List: if (valueStr.contains(","))
            value = Arrays.asList(valueStr.split(","));
        }
        // TODO: any other useful types to convert?
        return value;
    }

    public static String getJwtToken(ExecutionContextFactoryImpl ecfi, Map<String, String> claims, Instant expiresAt) {
        jwtCache = ecfi.cacheFacade.getCache("jwt.token");
        if (jwtCache.get("token") == null) {
            jwtCache.put("token", createJwt(claims, expiresAt));
        }
        return jwtCache.get("token");
    }
    public static String createJwt(Map<String, String> claims, Instant expiresAt) {
        String key = getJWTKey();

        JWTCreator.Builder builder = JWT.create()
                .withIssuedAt(ZonedDateTime.now().toInstant())
                .withExpiresAt(expiresAt)
                .withIssuer(SystemBinding.getPropOrEnv("ofbiz.instance.name"));
        for (Map.Entry<String, String> entry : claims.entrySet()) {
            builder.withClaim(entry.getKey(), entry.getValue());
        }
        return builder.sign(Algorithm.HMAC512(key));
    }

    protected static String getJWTKey() {
        return SystemBinding.getPropOrEnv("jwt.secret.key");
    }

}
