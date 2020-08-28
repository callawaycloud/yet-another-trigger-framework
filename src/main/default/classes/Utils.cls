public class Utils {
    public static String getClassName(Object h) {
        // thanks https://salesforce.stackexchange.com/a/24002/594
        return String.valueOf(h).split(':')[0].toLowerCase();
    }

    public static Object constructFromName(String className) {
        Type t = Type.forName(className);
        if (t == null) {
            throw new TypeException(className + ' does not exist');
        }
        return t.newInstance();
    }
}
