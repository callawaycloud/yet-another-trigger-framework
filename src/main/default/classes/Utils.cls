public class Utils {
    public static String getClassName(Object h) {
        // thanks https://salesforce.stackexchange.com/a/24002/594
        return String.valueOf(h).split(':')[0].toLowerCase();
    }

    public static Object constructFromName(String className) {
        return constructFromName(className, null);
    }

    public static Object constructFromName(String className, String props) {
        Type t = Type.forName(className);
        if (t == null) {
            throw new TypeException(className + ' does not exist');
        }
        if (props == null) {
            return t.newInstance();
        } else {
            return JSON.deserialize(props, t);
        }
    }

    public static Object parseEnum(string enumString, Type enumType) {
        Type cType = Type.forName(String.format('List<{0}>', new List<String>{ enumType.getName() }));
        return ((List<Object>) JSON.deserialize(String.format('["{0}"]', new List<String>{ enumString }), cType))[0];
    }
}
