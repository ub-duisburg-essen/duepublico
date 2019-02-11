package unidue.ub.duepublico.authorization;

import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.Set;
import java.util.StringJoiner;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.jdom2.Element;
import org.mycore.access.strategies.MCRAccessCheckStrategy;
import org.mycore.common.MCRCache;
import org.mycore.common.MCRException;
import org.mycore.common.MCRSession;
import org.mycore.common.MCRSessionMgr;
import org.mycore.common.MCRUserInformation;
import org.mycore.common.events.MCREvent;
import org.mycore.common.events.MCREventHandlerBase;
import org.mycore.common.events.MCREventManager;
import org.mycore.common.xml.MCRURIResolver;
import org.mycore.datamodel.classifications2.MCRCategoryID;
import org.mycore.datamodel.metadata.MCRDerivate;
import org.mycore.datamodel.metadata.MCRMetadataManager;
import org.mycore.datamodel.metadata.MCRObject;
import org.mycore.datamodel.metadata.MCRObjectID;
import org.mycore.datamodel.metadata.MCRObjectService;
import org.mycore.mir.authorization.MIROwnerStrategy;
import org.mycore.mods.MCRMODSWrapper;
import org.mycore.user2.MCRUserManager;

public class UDEStrategy extends MIROwnerStrategy implements MCRAccessCheckStrategy {

    private static final Logger LOGGER = LogManager.getLogger();

    private Condition rules;

    public UDEStrategy() {
        this.rules = buildRulesFromXML();
    }

    private Condition buildRulesFromXML() {
        Element eRules = MCRURIResolver.instance().resolve("resource:rules.xml");
        return ConditionFactory.parse(eRules);
    }

    @Override
    public boolean checkPermission(String id, String permission) {
        if ((id != null) && MCRObjectID.isValid(id)) {
            String action = permission.replaceAll("db$", ""); // writedb -> write

            MCRObjectID oid = MCRObjectID.getInstance(id);
            String target = "metadata"; // metadata|files

            if ("derivate".equals(oid.getTypeId())) {
                target = "files";
                MCRDerivate deriv = MCRMetadataManager.retrieveMCRDerivate(oid);
                id = deriv.getOwnerID().toString();
            }

            String cacheKey = action + " " + id + " " + target;
            LOGGER.debug("Testing {} ", cacheKey);

            Facts facts = new Facts();
            facts.add(ConditionFactory.build("id", id));
            facts.add(ConditionFactory.build("action", action));
            facts.add(ConditionFactory.build("target", target));

            boolean result = rules.matches(facts);
            LOGGER.info("Checked permission to {} := {}", cacheKey, result);
            return result;
        } else {
            return super.checkPermission(id, permission);
        }
    }
}

class Facts {

    private Set<SimpleCondition> facts = new HashSet<SimpleCondition>();

    void add(SimpleCondition condition) {
        facts.add(condition);
    }

    boolean isFact(SimpleCondition condition) {
        return facts.contains(condition);
    }

    SimpleCondition require(String type) {
        Optional<SimpleCondition> osc = facts.stream().filter(c -> type.equals(c.getType())).findFirst();
        if (osc.isPresent()) {
            return osc.get();
        } else {
            SimpleCondition sc = (SimpleCondition) (ConditionFactory.build(type));
            sc.setCurrentValue(this);
            facts.add(sc);
            return sc;
        }
    }

    @Override
    public String toString() {
        StringJoiner sj = new StringJoiner(" & ");
        facts.stream().forEach(f -> sj.add(f.toString()));
        return sj.toString();
    }
}

class ConditionFactory {

    static Map<String, Class<? extends Condition>> type2class = new HashMap<String, Class<? extends Condition>>();

    static {
        type2class.put("and", AndCondition.class);
        type2class.put("or", OrCondition.class);
        type2class.put("not", NotCondition.class);
        type2class.put("target", SimpleCondition.class);
        type2class.put("action", SimpleCondition.class);
        type2class.put("id", IDCondition.class);
        type2class.put("user", UserCondition.class);
        type2class.put("role", RoleCondition.class);
        type2class.put("status", StatusCondition.class);
        type2class.put("createdBy", CreatedByCondition.class);
        type2class.put("collection", CollectionCondition.class);
    }

    static Condition parse(Element xml) {
        String type = xml.getName();
        Condition cond = build(type);
        cond.parse(xml);
        return cond;
    }

    static SimpleCondition build(String type, String value) {
        SimpleCondition condition = (SimpleCondition) (build(type));
        condition.setValue(value);
        return condition;
    }

    static Condition build(String type) {
        try {
            Condition condition = type2class.get(type).newInstance();
            if (condition instanceof SimpleCondition) {
                ((SimpleCondition) condition).setType(type);
            }
            return condition;
        } catch (InstantiationException | IllegalAccessException ex) {
            throw new MCRException(ex);
        }
    }
}

interface Condition {

    public boolean matches(Facts facts);

    public void parse(Element xml);
}

abstract class CombinedCondition implements Condition {

    protected Set<Condition> conditions = new HashSet<Condition>();

    public void add(Condition condition) {
        conditions.add(condition);
    }

    public void parse(Element xml) {
        for (Element child : xml.getChildren()) {
            conditions.add(ConditionFactory.parse(child));
        }
    }
}

class OrCondition extends CombinedCondition {

    public boolean matches(Facts facts) {
        return conditions.stream().anyMatch(c -> c.matches(facts));
    }
}

class AndCondition extends CombinedCondition {

    public boolean matches(Facts facts) {
        return conditions.stream().allMatch(c -> c.matches(facts));
    }
}

class NotCondition implements Condition {

    private Condition negatedCondition;

    public boolean matches(Facts facts) {
        return !negatedCondition.matches(facts);
    }

    public void parse(Element xml) {
        negatedCondition = ConditionFactory.parse(xml.getChildren().get(0));
    }
}

class SimpleCondition implements Condition {

    static final String UNDEFINED = "undefined";

    protected String value = UNDEFINED;

    protected String type;

    void setType(String type) {
        this.type = type;
    }

    String getType() {
        return type;
    }

    @Override
    public void parse(Element xml) {
        this.value = xml.getTextTrim();
    }

    void setValue(String value) {
        this.value = value;
    }

    void setCurrentValue(Facts facts) {
        this.value = UNDEFINED;
    }

    public boolean matches(Facts facts) {
        return facts.isFact(this);
    }

    @Override
    public boolean equals(Object obj) {
        if (obj instanceof SimpleCondition) {
            SimpleCondition other = (SimpleCondition) obj;
            return this.value.equals(other.value) && this.type.equals(other.type);

        } else {
            return false;
        }
    }

    @Override
    public int hashCode() {
        return value.hashCode();
    }

    @Override
    public String toString() {
        return type + "=" + value;
    }
}

class UserCondition extends SimpleCondition {

    @Override
    public boolean matches(Facts facts) {
        facts.require(this.type);
        return super.matches(facts);
    }

    @Override
    void setCurrentValue(Facts facts) {
        MCRSession session = MCRSessionMgr.getCurrentSession();
        MCRUserInformation user = session.getUserInformation();
        if (user != null) {
            this.value = user.getUserID();
        }
    }
}

class RoleCondition extends SimpleCondition {

    @Override
    public boolean matches(Facts facts) {
        String factUserID = facts.require("user").value;

        if (!super.matches(facts)) {
            MCRSession session = MCRSessionMgr.getCurrentSession();
            MCRUserInformation user = session.getUserInformation();

            if (!factUserID.equals(user.getUserID())) {
                // Check against a given user, not the current one
                user = MCRUserManager.getUser(factUserID);
            }
            if (user.isUserInRole(value)) {
                facts.add(this);
            }
        }
        return super.matches(facts);
    }
}

class IDCondition extends SimpleCondition {

    private MCRObjectID oid;

    void setValue(String value) {
        this.value = value;
        this.oid = MCRObjectID.getInstance(value);
    }

    @Override
    public boolean matches(Facts facts) {
        facts.require(this.type);
        return super.matches(facts);
    }

    MCRObject getObject() {
        return ObjectFactory.instance().getObject(oid);
    }
}

class ObjectFactory extends MCREventHandlerBase {

    private static final Logger LOGGER = LogManager.getLogger();

    private static final ObjectFactory SINGLETON = new ObjectFactory();

    private static final int CACHE_MAX_SIZE = 100;

    static ObjectFactory instance() {
        return SINGLETON;
    }

    private MCRCache<MCRObjectID, MCRObject> OBJECT_CACHE;

    private ObjectFactory() {
        OBJECT_CACHE = new MCRCache<MCRObjectID, MCRObject>(CACHE_MAX_SIZE, this.getClass().getName());
        MCREventManager.instance().addEventHandler(MCREvent.OBJECT_TYPE, this);
    }

    MCRObject getObject(MCRObjectID oid) {
        MCRObject obj = OBJECT_CACHE.get(oid);
        if (obj == null) {
            LOGGER.debug("reading object {} from metadata manager", oid);
            obj = MCRMetadataManager.retrieveMCRObject(oid);
            OBJECT_CACHE.put(oid, obj);
        } else {
            LOGGER.debug("reading object {} from cache", oid);
        }

        return obj;
    }

    @Override
    protected void handleObjectDeleted(MCREvent evt, MCRObject obj) {
        OBJECT_CACHE.remove(obj.getId());
        LOGGER.debug("removing object {} from cache", obj.getId());
    }

    @Override
    protected void handleObjectRepaired(MCREvent evt, MCRObject obj) {
        OBJECT_CACHE.remove(obj.getId());
        LOGGER.debug("removing object {} from cache", obj.getId());
    }

    @Override
    protected void handleObjectUpdated(MCREvent evt, MCRObject obj) {
        OBJECT_CACHE.remove(obj.getId());
        LOGGER.debug("removing object {} from cache", obj.getId());
    }
}

class StatusCondition extends SimpleCondition {

    @Override
    public boolean matches(Facts facts) {
        facts.require(this.type);
        return super.matches(facts);
    }

    @Override
    void setCurrentValue(Facts facts) {
        IDCondition idc = (IDCondition) (facts.require("id"));
        MCRObjectService service = idc.getObject().getService();
        MCRCategoryID status = service.getState();
        if (status != null) {
            value = status.getID();
        }
    }
}

class CreatedByCondition extends SimpleCondition {

    @Override
    public boolean matches(Facts facts) {
        String createdBy = facts.require(this.type).value;
        String userID = value.equals("currentUser") ? facts.require("user").value : value;
        if (userID.equals(createdBy)) {
            facts.add(this);
        }
        return super.matches(facts);
    }

    @Override
    void setCurrentValue(Facts facts) {
        IDCondition idc = (IDCondition) (facts.require("id"));
        MCRObjectService service = idc.getObject().getService();
        List<String> flags = service.getFlags("createdby");
        if ((flags != null) && !flags.isEmpty()) {
            this.value = flags.get(0);
        }
    }
}

class CollectionCondition extends SimpleCondition {

    private static final String XPATH_COLLECTION = "mods:classification[contains(@valueURI,'/collection#')]";

    @Override
    public boolean matches(Facts facts) {
        facts.require(this.type);
        return super.matches(facts);
    }

    @Override
    void setCurrentValue(Facts facts) {
        IDCondition idc = (IDCondition) (facts.require("id"));
        MCRMODSWrapper wrapper = new MCRMODSWrapper(idc.getObject());

        List<Element> e = wrapper.getElements(XPATH_COLLECTION);
        if ((e != null) && !(e.isEmpty())) {
            String valueURI = e.get(0).getAttributeValue("valueURI");
            this.value = valueURI.split("#")[1];
        }
    }
}
