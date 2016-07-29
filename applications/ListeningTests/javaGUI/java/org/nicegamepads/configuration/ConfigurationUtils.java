package org.nicegamepads.configuration;

import java.util.Map;

/**
 * Utilities for working with our configuration objects.  This is nontrivial
 * because we store floats and such in properties files, which means we have
 * to have canonical representations of them in non-obvious form.
 * <p>
 * This class is threadsafe.
 * 
 * @author ahayden
 */
public final class ConfigurationUtils
{
    /**
     * Private constructor discourages unwanted instantiation.
     */
    private ConfigurationUtils() {
        // Private constructor discourages unwanted instantiation.
    }

    /**
     * Returns a required float
     * (<strong>which must be in the form emitted by
     * {@link #floatToHexBitString(float)}</strong>)
     * from a map using the specified key.
     * 
     * @param map the map in which to perform the lookup
     * @param key the key under which the value is expected to live
     * @return the value bound to the specified key
     * @throws ConfigurationException if the value is not found or if the
     * value cannot be parsed as expected
     */
    public final static float getFloat(final Map<String,String> map, final String key)
    throws ConfigurationException {
        final String value = map.get(key);
        if (value == null) {
            throw new ConfigurationException("No such key: " + key);
        }

        try {
            return floatFromHexBitString(value);
        } catch(NumberFormatException e) {
            throw new ConfigurationException("Configuration is corrupt.  Key '"
                    + key + "' should refer to Float, but instead refers to "
                    + "value '" + value + "'");
        }
    }

    /**
     * Returns an optional float
     * (<strong>which must be in the form emitted by
     * {@link #floatToHexBitString(float)}</strong>, if present)
     * from a map using the specified key.
     * 
     * @param map the map in which to perform the lookup
     * @param key the key under which the value is expected to live
     * @param defaultValue default value to return if the value is not bound
     * to the specified key
     * @return the value bound to the specified key, or the default value
     * otherwise
     * @throws ConfigurationException if the
     * value cannot be parsed as expected
     */
    public final static float getFloat(final Map<String,String> map, final String key, final float defaultValue)
    throws ConfigurationException {
        final String value = map.get(key);
        if (value == null) {
            return defaultValue;
        }

        try {
            return floatFromHexBitString(value);
        } catch(NumberFormatException e) {
            throw new ConfigurationException("Configuration is corrupt.  Key '"
                    + key + "' should refer to Float, but instead refers to "
                    + "value '" + value + "'");
        }
    }

    /**
     * Returns a required boolean from a map using the specified key.
     * 
     * @param map the map in which to perform the lookup
     * @param key the key under which the value is expected to live
     * @return the value bound to the specified key
     * @throws ConfigurationException if the value is not found or if the
     * value cannot be parsed as expected
     */
    public final static boolean getBoolean(final Map<String,String> map, final String key)
    throws ConfigurationException {
        final String value = map.get(key);
        if (value == null) {
            throw new ConfigurationException("No such key: " + key);
        }

        if (value.equalsIgnoreCase("true")) {
            return true;
        } else if (value.equalsIgnoreCase("false")) {
            return false;
        } else {
            throw new ConfigurationException("Configuration is corrupt.  Key '"
                    + key + "' should refer to Boolean, but instead refers to "
                    + "value '" + value + "'");
        }
    }

    /**
     * Returns an optional boolean from a map using the specified key.
     * 
     * @param map the map in which to perform the lookup
     * @param key the key under which the value is expected to live
     * @param defaultValue default value to return if the value is not bound
     * to the specified key
     * @return the value bound to the specified key, or the default value
     * otherwise
     * @throws ConfigurationException if the
     * value cannot be parsed as expected
     */
    public final static boolean getBoolean(final Map<String,String> map, final String key, final boolean defaultValue)
    throws ConfigurationException {
        final String value = map.get(key);
        if (value == null) {
            return defaultValue;
        }

        if (value.equalsIgnoreCase("true")) {
            return true;
        } else if (value.equalsIgnoreCase("false")) {
            return false;
        } else {
            throw new ConfigurationException("Configuration is corrupt.  Key '"
                    + key + "' should refer to Boolean, but instead refers to "
                    + "value '" + value + "'");
        }
    }

    /**
     * Returns a required string from a map using the specified key.
     * 
     * @param map the map in which to perform the lookup
     * @param key the key under which the value is expected to live
     * @return the value bound to the specified key
     * @throws ConfigurationException if the value is not found or if the
     * value cannot be parsed as expected
     */
    public final static String getString(final Map<String,String> map, final String key)
    throws ConfigurationException {
        final String value = map.get(key);
        if (value == null) {
            throw new ConfigurationException("No such key: " + key);
        }
        return value;
    }

    /**
     * Returns an optional string from a map using the specified key.
     * 
     * @param map the map in which to perform the lookup
     * @param key the key under which the value is expected to live
     * @param defaultValue default value to return if the value is not bound
     * to the specified key
     * @return the value bound to the specified key, or the default value
     * otherwise
     */
    public final static String getString(final Map<String,String> map, final String key, final String defaultValue)
    {
        final String value = map.get(key);
        if (value == null) {
            return defaultValue;
        }
        return value;
    }

    /**
     * Returns a required int from a map using the specified key.
     * 
     * @param map the map in which to perform the lookup
     * @param key the key under which the value is expected to live
     * @return the value bound to the specified key
     * @throws ConfigurationException if the value is not found or if the
     * value cannot be parsed as expected
     */
    public final static int getInteger(final Map<String,String> map, final String key)
    throws ConfigurationException {
        final String value = map.get(key);
        if (value == null) {
            throw new ConfigurationException("No such key: " + key);
        }

        try {
            return Integer.parseInt(value);
        } catch(NumberFormatException e) {
            throw new ConfigurationException("Configuration is corrupt.  Key '"
                    + key + "' should refer to Integer, but instead refers to "
                    + "value '" + value + "'");
        }
    }

    /**
     * Returns an optional int from a map using the specified key.
     * 
     * @param map the map in which to perform the lookup
     * @param key the key under which the value is expected to live
     * @param defaultValue default value to return if the value is not bound
     * to the specified key
     * @return the value bound to the specified key, or the default value
     * otherwise
     * @throws ConfigurationException if the
     * value cannot be parsed as expected
     */
    public final static int getInteger(final Map<String,String> map, final String key, final int defaultValue)
    throws ConfigurationException {
        final String value = map.get(key);
        if (value == null) {
            return defaultValue;
        }

        try {
            return Integer.parseInt(value);
        } catch(NumberFormatException e) {
            throw new ConfigurationException("Configuration is corrupt.  Key '"
                    + key + "' should refer to Integer, but instead refers to "
                    + "value '" + value + "'");
        }
    }

    /**
     * Returns a required long from a map using the specified key.
     * 
     * @param map the map in which to perform the lookup
     * @param key the key under which the value is expected to live
     * @return the value bound to the specified key
     * @throws ConfigurationException if the value is not found or if the
     * value cannot be parsed as expected
     */
    public final static long getLong(final Map<String,String> map, final String key)
    throws ConfigurationException
    {
        final String value = map.get(key);
        if (value == null) {
            throw new ConfigurationException("No such key: " + key);
        }

        try {
            return Long.parseLong(value);
        } catch(NumberFormatException e) {
            throw new ConfigurationException("Configuration is corrupt.  Key '"
                    + key + "' should refer to Long, but instead refers to "
                    + "value '" + value + "'");
        }
    }

    /**
     * Returns an optional long from a map using the specified key.
     * 
     * @param map the map in which to perform the lookup
     * @param key the key under which the value is expected to live
     * @param defaultValue default value to return if the value is not bound
     * to the specified key
     * @return the value bound to the specified key, or the default value
     * otherwise
     * @throws ConfigurationException if the
     * value cannot be parsed as expected
     */
    public final static long getLong(final Map<String,String> map, final String key, final long defaultValue)
    throws ConfigurationException
    {
        final String value = map.get(key);
        if (value == null) {
            return defaultValue;
        }

        try {
            return Long.parseLong(value);
        } catch(NumberFormatException e) {
            throw new ConfigurationException("Configuration is corrupt.  Key '"
                    + key + "' should refer to Long, but instead refers to "
                    + "value '" + value + "'");
        }
    }

    /**
     * Converts a floating point value to a raw bit value in hexadecimal
     * suitable for storage.
     * 
     * @param value the value to convert
     * @return a hexadecimal representation of the bit pattern of the floating
     * point value as if it were an unsigned int
     */
    public final static String floatToHexBitString(final float value) {
        return Integer.toHexString(Float.floatToRawIntBits(value));
    }

    /**
     * Converts a string previously generated by
     * {@link #floatToHexBitString(float)} back into the same exact
     * floating point representation (bit for bit) as the original.
     * 
     * @param value the value to convert back into a float
     * @return an exact copy of the float that was the input to
     * {@link #floatToHexBitString(float)}
     * @throws NumberFormatException if the string doesn't appear to be
     * a valid floating point number; note that this does not prevent
     * against all forms of corruption, since many valid strings will parse
     * to a floating point bit pattern in hex
     */
    public final static float floatFromHexBitString(final String value)
    throws NumberFormatException {
        long asLong = Long.parseLong(value, 16);
        // 0xFFFFFFFF00000000 is 32 bits of 1's followed bt 32 bits of 0's
        // That is, it is a mask for values greater than the largest possible
        // unsigned 32-bit integer
        if ( (asLong & 0xFFFFFFFF00000000L) != 0) {
            // String contains more than 32 bits of data!
            throw new NumberFormatException(
                    "Bit string representation contains more than 32 bits "
                    + "of data: " + value);
        }

        final int lsb = (int) (asLong & 0x1L);
        int rawBits = (int) (asLong >> 1);
        rawBits <<= 1;
        rawBits |= lsb;
        return Float.intBitsToFloat(rawBits);
    }
}