package org.nicegamepads.configuration;

import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.Map;
import java.util.Set;
import java.util.TreeSet;

import org.nicegamepads.NiceControl;

/**
 * Logical configuration for a single component.
 * <p>
 * This class is threadsafe and immutable.
 * <p>
 * <h2>Inversion, Granularity, Dead Zone and Center Values</h2>
 * This class allows you to specify the four properties listed above.
 * Obviously, these values can interact in complex ways.  In this section
 * we describe exactly how these properties should be processed to produce
 * unambiguous results.
 * <p>
 * <strong>Important:</strong> since the values involved in these calculations
 * are floating point values, there are fundamental precision limits that must
 * be taken into account.  In particular, be aware that any operation that
 * changes the value returned by the component has the potential to cause
 * a loss of precision in the floating-point representation and, as such,
 * to interfere with the value bindings of this object (
 * see {@link #setValueId(float, int)} for more information on binding values).
 * Plan accordingly.
 * <p>
 * Also, while reading this section bear in mind that buttons return values
 * in the range [0,1] while other components return values in the range
 * [-1,1]; thus the meaning of "the center of the range" may be taken to
 * mean either 0.5 (in the case of buttons) or 0.0 (in the case of everything
 * else).
 * <p>
 * <ol>
 *  <li>Poll the raw value for the component.</li>
 *  <li>If the granularity has been set, divide the range of possible
 *      values into bins, starting at zero and proceeding symmetrically
 *      in both the positive and negative directions incrementing by the amount
 *      of granularity specified.  Clamp the polled value to the nearest
 *      bin boundary in the direction of zero (for example,
 *      analog stick values bin towards the center and buttons bin towards
 *      their natural "not pressed" value).  Note that this means that the
 *      granularity values are absolute, and are not affected by any
 *      centering work.</li>
 *  <li>Check the value against the dead zone.  If the polled value is in the
 *      dead zone (boundaries inclusive), set the polled value to zero.
 *      Note that this means that the dead zone boundaries are absolute,
 *      and are not affected by any centering work.</li>
 *  <li>If inversion is on, flip the polled value around the center of the
 *      range.  For buttons this means that 0 becomes 1 and 1 becomes 0; for all
 *      other types of controls, this means that -1 becomes 1 and 1 becomes
 *      -1 (0 stays as 0).  Note that this means that inversion is absolute,
 *      and is not affected by any centering work.</li>
 *  <li>If the center value override has been set (that is, is not the value
 *      {@link Float#NaN}, calculate the percentage of difference
 *      between the new override value and the natural center of the range.
 *      Multiply the polled value to map into the new range in the same
 *      proportions as the range center has moved; that is, the side of the
 *      range that has shrunk compresses all values by the shrink percentage,
 *      while the side of the range that has expanded expands all values
 *      by the expand percentage.  For example, if the range of an analog
 *      stick is modified such that the center is moved from 0.0 to 0.5,
 *      then the negative side of the range has expanded to 150% of its
 *      original size while the positive side of the range has shrunk to
 *      50% of its size; if the polled value is less than the new center
 *      it is multiplied by 1.5, if the polled value is greater than the
 *      new center it is multiplied by 0.5, and if the polled value is
 *      exactly the new center then it is left unchanged.</li>
 *  <li>Finally, clamp the polled value into its original range (again,
 *      this is [0,1] for buttons and [-1,1] for everything else); this
 *      is to prevent any floating point precision loss from placing the
 *      value just outside of the allowed range.</li>
 * </ol>
 * As you can see from the above information, centering is the last operation
 * and the most likely to cause floating point precision loss issues.  It is
 * strongly recommended that centering not be changed dynamically in the
 * presence of bound values for this reason.
 * 
 * @author Andrew Hayden
 */
public class ControlConfiguration
{
    /**
     * The lower bound of the dead zone, if any (inclusive).
     */
    private final float deadZoneLowerBound;

    /**
     * The upper bound of the dead zone, if any (inclusive).
     */
    private final float deadZoneUpperBound;

    /**
     * The granularity, if any.
     */
    private final float granularity;

    /**
     * Whether or not this is an inverted configuration.
     */
    private final boolean isInverted;

    /**
     * Whether or not turbo mode is enabled.
     */
    private final boolean isTurboEnabled;

    /**
     * How long, in milliseconds, after which a pushed button automatically
     * enters turbo mode.
     */
    private final long turboDelayMillis;

    /**
     * The value at the center of the range.
     */
    private final float centerValueOverride;

    /**
     * "Map" whose keys are discrete floats produced by this control, if it
     * is digital, and whose values are the user-defined symbols associated
     * therewith.
     */
    private final Map<Float, Integer> valueIdsByValue;

    /**
     * User-defined ID for this component.
     */
    private final int userDefinedId;

    /**
     * The control whose configuration this is.
     */
    private final NiceControl control;

    /**
     * Creates a new, empty configuration with default values.
     */
    public ControlConfiguration(final ControlConfigurationBuilder builder)
    {
        this.control = builder.getControl();
        this.centerValueOverride = builder.getCenterValueOverride();
        this.deadZoneLowerBound = builder.getDeadZoneLowerBound();
        this.deadZoneUpperBound = builder.getDeadZoneUpperBound();
        this.granularity = builder.getGranularity();
        this.isInverted = builder.isInverted();
        this.isTurboEnabled = builder.isTurboEnabled();
        this.turboDelayMillis = builder.getTurboDelayMillis();
        this.userDefinedId = builder.getUserDefinedId();
        this.valueIdsByValue = Collections.unmodifiableMap(new HashMap<Float, Integer>(builder.getValueIdsByValue()));
    }

    /**
     * Saves this partial configuration to a mapping of (key,value) pairs
     * in an unambiguous manner suitable for user in a Java properties file.
     * <p>
     * The specified prefix, with an added trailing "." character, is
     * prepended to the names of all properties written by this method.
     * 
     * @param prefix the prefix to use for creating the property keys
     * @param destination optionally, a map into which the properties should
     * be written; if <code>null</code>, a new map is created and returned.
     * Any existing entries with the same names are overwritten.
     * @return if <code>destination</code> was specified, the reference to
     * that same object (which now contains this configuration's (key,value)
     * pairs); otherwise, a new {@link Map} containing this configuration's
     * (key,value) pairs
     */
    public final Map<String, String> saveToProperties(final String prefix, Map<String,String> destination) {
        if (destination == null) {
            destination = new HashMap<String, String>();
        }

        destination.put(prefix + ".userDefinedId", Integer.toString(getUserDefinedId()));
        destination.put(prefix + ".centerValue", ConfigurationUtils.floatToHexBitString(getCenterValueOverride()));
        destination.put(prefix + ".deadZoneLowerBound", ConfigurationUtils.floatToHexBitString(getDeadZoneLowerBound()));
        destination.put(prefix + ".deadZoneUpperBound", ConfigurationUtils.floatToHexBitString(getDeadZoneUpperBound()));
        destination.put(prefix + ".granularity", ConfigurationUtils.floatToHexBitString(getGranularity()));
        destination.put(prefix + ".isInverted", Boolean.toString(isInverted()));
        destination.put(prefix + ".isTurboEnabled", Boolean.toString(isTurboEnabled()));
        destination.put(prefix + ".turboDelayMillis", Long.toString(getTurboDelayMillis()));

        // Serialize list of values that are bound.
        final StringBuilder buffer = new StringBuilder();
        final Set<Float> keysAsFloat = new TreeSet<Float>(getValueIdsByValue().keySet());
        final Iterator<Float> keyIterator = keysAsFloat.iterator();
        while(keyIterator.hasNext()) {
            final Float key  = keyIterator.next();

            // Output the (key,value) pair for this binding
            final String stringKey = ConfigurationUtils.floatToHexBitString(key);
            destination.put(prefix + ".userDefinedSymbolKey." + stringKey,
                    Integer.toString(getValueIdsByValue().get(key)));

            // Then add the key itself to the running list of keys.
            buffer.append(stringKey);
            if (keyIterator.hasNext()) {
                buffer.append(",");
            }
        }
        destination.put(prefix + ".userDefinedSymbolKeysList", buffer.toString());
        return destination;
    }



    /**
     * Returns all of the values that have IDs bound via
     * {@link #setValueId(float, int)}, in no particular order.
     * 
     * @return the values as an array (possibly of length zero but never
     * <code>null</code>)
     */
    public final float[] getAllValuesWithIds() {
        final float[] values = new float[getValueIdsByValue().size()];
        int counter = 0;
        for (final float f : getValueIdsByValue().keySet()) {
            values[counter++] = f;
        }
        return values;
    }

    /**
     * Returns all of the IDs that have been vound to values via
     * {@link #setValueId(float, int)}, in no particular order.
     * <p>
     * Note that multiple values may be bound to the same ID.  The returned
     * array will not contain any duplicate values.
     * 
     * @return the ids as an array (possibly of length zero but never
     * <code>null</code>), excluding any duplicates
     */
    public final int[] getAllValueIds() {
        final Set<Integer> asSet = new HashSet<Integer>(getValueIdsByValue().values());
        final int[] ids = new int[asSet.size()];
        int counter = 0;
        for (final int i : asSet) {
            ids[counter++] = i;
        }
        return ids;
    }

    /**
     * Returns the user-defined ID for the specified value.
     * <p>
     * For more information about binding user-defined IDs to values,
     * please see {@link #setValueId(float, int)}.
     * 
     * @param value the value to look up
     * @return if a user-defined ID is bound to the specified value,
     * that ID; otherwise, {@link Integer#MIN_VALUE}
     * (this special value cannot be bound by the
     * {@link #setValueId(float, int)} method)
     */
    public final int getValueId(final float value) {
        final Integer storedValue = getValueIdsByValue().get(value);
        final int result;
        if (storedValue == null) {
            result = Integer.MIN_VALUE;
        } else {
            result = storedValue.intValue();
        }
        return result;
    }

    /**
     * Returns the lower bound of the dead zone for this component.
     * 
     * @return if a valid bound has been set, that lower bound,
     * which must be in the range [-1.0, 1.0]; otherwise, {@link Float#NaN}
     */
    public final float getDeadZoneLowerBound() {
        return deadZoneLowerBound;
    }

    /**
     * Returns the upper bound of the dead zone for this component.
     * 
     * @return if a valid bound has been set, that lower bound,
     * which must be in the range [-1.0, 1.0]; otherwise, {@link Float#NaN}
     */
    public final float getDeadZoneUpperBound() {
        return deadZoneUpperBound;
    }

    /**
     * Returns the center value for this component.
     * 
     * @return the center value for this component
     * @see #setCenterValueOverride(float)
     */
    public final float getCenterValueOverride() {
        return centerValueOverride;
    }

    /**
     * Returns the granularity of this component, if any.
     * 
     * @return if granularity has been set, the granularity, which must be
     * in the range [0,1]
     * @see #setGranularity(float)
     */
    public final float getGranularity() {
        return granularity;
    }

    /**
     * Returns whether or not the component is inverted.
     * 
     * @return <code>true</code> if the component is inverted; otherwise,
     * <code>false</code>
     */
    public final boolean isInverted() {
        return isInverted;
    }

    /**
     * Returns whether or not the component is in turbo mode.
     * 
     * @return <code>true</code> if the component is in turbo mode; otherwise,
     * <code>false</code>
     */
    public final boolean isTurboEnabled() {
        return isTurboEnabled;
    }

    /**
     * Returns the delay, in milliseconds, after which turbo behavior is
     * activated if turbo mode is enabled.
     * <p>
     * If turbo mode is not enabled, this value is meaningless.
     * <p>
     * See {@link #setTurboDelayMillis(long)} for more information.
     * 
     * @return the delay, in milliseconds
     * @see #setTurboDelayMillis(long)
     */
    public final long getTurboDelayMillis() {
        return turboDelayMillis;
    }

    /**
     * Returns the user-defined identifier for this component.
     * <p>
     * This value is an integer.  For a discussion of why the ID must be
     * an integer, please refer to {@link #setUserDefinedId(int)}.
     * 
     * @return the integer value that represents the user-defined ID of the
     * component associated with this configuration
     */
    public final int getUserDefinedId() {
        return userDefinedId;
    }

    @Override
    public String toString() {
        StringBuilder buffer = new StringBuilder();
        buffer.append(ControlConfiguration.class.getName());
        buffer.append(": [");
        buffer.append("userDefinedId=");
        buffer.append(getUserDefinedId());
        buffer.append(", granularity=");
        buffer.append(getGranularity());
        buffer.append(", deadZoneLowerBound=");
        buffer.append(getDeadZoneLowerBound());
        buffer.append(", deadZoneUpperBound=");
        buffer.append(getDeadZoneUpperBound());
        buffer.append(", isInverted=");
        buffer.append(isInverted());
        buffer.append(", centerValueOverride=");
        buffer.append(getCenterValueOverride());
        buffer.append(", isTurboEnabled=");
        buffer.append(isTurboEnabled());
        buffer.append(", turboDelayMillis=");
        buffer.append(getTurboDelayMillis());
        buffer.append(", valueIdsByValue=[");
        final Iterator<Map.Entry<Float, Integer>> iterator = getValueIdsByValue().entrySet().iterator();
        while(iterator.hasNext()) {
            Map.Entry<Float, Integer> entry = iterator.next();
            buffer.append(entry.getKey());
            buffer.append("=");
            buffer.append(entry.getValue());
            if (iterator.hasNext()) {
                buffer.append(",");
            }
        }
        buffer.append("]");
        buffer.append("]");
        return buffer.toString();
    }

    public final Map<Float, Integer> getValueIdsByValue() {
        return valueIdsByValue;
    }

    public final NiceControl getControl() {
        return control;
    }
}