package org.nicegamepads.configuration;

import java.util.HashMap;
import java.util.Map;

import org.nicegamepads.NiceControl;

/**
 * Builder to generate a {@link ControlConfiguration}.  See that class for all
 * the various details about what each field means, etceteras.
 * <p>
 * This class is threadsafe.
 * 
 * @author ahayden
 */
public class ControlConfigurationBuilder {
    private float deadZoneLowerBound = Float.NaN;
    private float deadZoneUpperBound = Float.NaN;
    private float granularity = Float.NaN;
    private boolean isInverted = false;
    private boolean isTurboEnabled = false;
    private long turboDelayMillis = 0L;
    private float centerValueOverride = Float.NaN;
    private Map<Float, Integer> valueIdsByValue = new HashMap<Float, Integer>();
    private int userDefinedId = Integer.MIN_VALUE;
    private final NiceControl control;

    public ControlConfigurationBuilder(final NiceControl control) {
        this.control = control;
    }

    /**
     * Loads all the settings from the specified configuration into this
     * configuration.  This method can be used to copy settings between
     * different controls and even between different controls on different
     * control<em>lers</em>.
     * 
     * @param other the source object to copy settings from
     */
    public ControlConfigurationBuilder (final NiceControl control, final ControlConfiguration source)
    {
        this.control = control;
        setUserDefinedId(source.getUserDefinedId());
        setDeadZoneLowerBound(source.getDeadZoneLowerBound());
        setDeadZoneUpperBound(source.getDeadZoneUpperBound());
        setGranularity(source.getGranularity());
        setInverted(source.isInverted());
        setTurboEnabled(source.isTurboEnabled());
        setCenterValueOverride(source.getCenterValueOverride());
        valueIdsByValue = new HashMap<Float,Integer>(source.getValueIdsByValue());
    }

    public synchronized ControlConfiguration build() {
        return new ControlConfiguration(this);
    }

    public synchronized float getDeadZoneLowerBound() {
        return deadZoneLowerBound;
    }

    public synchronized float getDeadZoneUpperBound() {
        return deadZoneUpperBound;
    }

    public synchronized float getGranularity() {
        return granularity;
    }

    public synchronized boolean isInverted() {
        return isInverted;
    }

    public synchronized boolean isTurboEnabled() {
        return isTurboEnabled;
    }

    public synchronized long getTurboDelayMillis() {
        return turboDelayMillis;
    }

    public synchronized float getCenterValueOverride() {
        return centerValueOverride;
    }

    public synchronized Map<Float, Integer> getValueIdsByValue() {
        return valueIdsByValue;
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
    public synchronized int getValueId(final float value) {
        final Integer storedValue = valueIdsByValue.get(value);
        final int result;
        if (storedValue == null) {
            result = Integer.MIN_VALUE;
        } else {
            result = storedValue.intValue();
        }
        return result;
    }

    public synchronized int getUserDefinedId() {
        return userDefinedId;
    }

    public NiceControl getControl() {
        return control;
    }

    /**
     * Sets the center value for this component.
     * <p>
     * The center value override defaults to {@link Float#NaN} and represents
     * the default center value for the component (i.e., the neutral
     * position of the component).  Relative components may not have a center
     * value; for example, a wheel may produce only relative measurements
     * as it is turned and therefore may not have a "center" value, since there
     * is no notion of an absolute value in this sense.
     * <p>
     * The center value is important when considering granularity.
     * See {@link #setGranularity(float)} for more information.
     * <p>
     * For information on how inversion, granularity, dead zones and
     * center values interact, please refer to the class-level documentation.
     * 
     * @param centerValueOverride the new center value overrideto set;
     * to clear the center value override, set to {@link Float#NaN}.
     * Valid non-NaN values must be in the range [-1,1].
     */
    public synchronized void setCenterValueOverride(final float centerValueOverride)
    {
        if (centerValueOverride != Float.NaN) {
            if (centerValueOverride < -1 || 1 < centerValueOverride) {
                throw new IllegalArgumentException(
                        "Center value override must be in the range [-1,1]: "
                        + centerValueOverride);
            }
        }
        this.centerValueOverride = centerValueOverride;
    }

    /**
     * Sets or clears (or both) the bounds of the dead zone for this component.
     * <p>
     * The bound bounds must be in the range [-1.0, 1.0] if they are to be
     * considered valid.  To clear a bound, set its value to
     * {@link Float#NaN}.
     * <p>
     * If both bounds are set and the lower bound is greater than the upper
     * bound, an exception is thrown.  If both bounds are equal, this
     * indicates that there is only one dead zone value and it is the
     * value specified.
     * <p>
     * For information on how inversion, granularity, dead zones and
     * center values interact, please refer to the class-level documentation.
     * <p>
     * It is not permissible to have one bound set and the other cleared.
     * 
     * @param lowerBound the new lower bound to set.  If NaN, the
     * bound is cleared; otherwise, the bound is set
     * @param upperBound the new lower bound to set.  If NaN, the
     * bound is cleared; otherwise, the bound is set
     * @throws IllegalArgumentException if either of the specified bounds are
     * valid floating point numbers and are outside of the range [-1.0, 1.0],
     * or if either of the specified bounds is an infinite value, or if
     * the bounds are both valid but the lower bound is greater than the
     * upper bound
     */
    public synchronized void setDeadZoneBounds(final float lowerBound, final float upperBound)
    {
        float lowerBoundResult = lowerBound;
        float upperBoundResult = upperBound;
    
        if (Float.isInfinite(lowerBound) || (lowerBound < -1f || 1f < lowerBound)) {
            throw new IllegalArgumentException(
                    "lower bound must be either NaN "
                    + "or a value in the range [-1,1]: " + lowerBound);
        } else if (Float.isNaN(lowerBound)) {
            lowerBoundResult = Float.NaN;
        }
    
        if (Float.isInfinite(upperBound) || (upperBound < -1f || 1f < upperBound)) {
            throw new IllegalArgumentException(
                    "upper bound must be either NaN "
                    + "or a value in the range [-1,1]: " + lowerBound);
        } else if (Float.isNaN(upperBound)) {
            upperBoundResult = Float.NaN;
        }
    
        if (lowerBoundResult != Float.NaN && upperBoundResult != Float.NaN) {
            // Last sanity check
            if (lowerBound > upperBound) {
                throw new IllegalArgumentException(
                        "lower bound must be less than or equal to "
                        + "upper bound: " + lowerBound + " > " + upperBound);
            }
        }
    
        if ((lowerBound == Float.NaN || upperBound == Float.NaN)
                && (lowerBound != Float.NaN || upperBound != Float.NaN)) {
            // Only one bound was set.  Unacceptable.
            throw new IllegalArgumentException("lower bound and upper bound "
                    + "must be set or cleared together.");
        }
    
        // Set new lower and upper bounds.
        setDeadZoneLowerBound(lowerBoundResult);
        setDeadZoneUpperBound(upperBoundResult);
    }

    public synchronized void setDeadZoneLowerBound(final float deadZoneLowerBound) {
        this.deadZoneLowerBound = deadZoneLowerBound;
    }

    public synchronized void setDeadZoneUpperBound(final float deadZoneUpperBound) {
        this.deadZoneUpperBound = deadZoneUpperBound;
    }

    /**
     * Sets or clears the granularity for this component.
     * <p>
     * The granularity is used to establish logical "bins" into which the
     * values produced by the component fall.  Crossing the boundary of
     * such a bin signals that a meaningful value change has taken place.
     * For example, if you have a highly sensitive component it may be able
     * to measure values to a precision of thousandths, such that a slight
     * breeze or vibration may cause the component to issue many value-changed
     * events for values such as .235, .236, .234 and so on;
     * setting a granularity allows the system to coalesce a range of values
     * into one logical "bin".  Only when the value crosses the boundary of
     * such a bin does the system dispatch a value-changed event.
     * <p>
     * For absoute components, granularity is always symmetric around the
     * center of the component (that is, components that don't produce
     * relative values like a wheel turning at a variable rate of speed).
     * <p>
     * For example, if the center value is zero (the default) and the
     * granularity is set to 0.25, then logical bins are established in
     * the following ranges:
     * <br>
     * <code>[-1.00, -0.75), [-0.75, -0.50), [-0.50, -0.25), [-0.25, 0.00),
     *       (0.00, 0.25], (0.25, 0.50], (0.50, 0.75], (0.75, 1.00]</code>
     * <p>
     * Notice that the actual center value is not included in any of these
     * ranges.  This makes sure that the component will notice a change
     * from one logical side of the component to the other logical side.
     * <p>
     * At first glance this would appear to be a problem, because the values
     * could fluctuate wildly around the center.  This is indeed true.  The
     * solution is to also configure a dead zone, using the method
     * {@link #setDeadZoneBounds(float, float)}, which will cause a specific
     * region of the component's values to coalesce to the center value.
     * See {@link #setDeadZoneBounds(float, float)} for more details.
     * <p>
     * Setting the granularity to {@link Float#NaN} causes any existing
     * granularity to be cleared.  If granularity is cleared, then no
     * binning is performed and every change of value that is detected by
     * the system may potentially generate a value-changed event.
     * <p>
     * For information on how inversion, granularity, dead zones and
     * center values interact, please refer to the class-level documentation.
     * 
     * @param granularity the new granularity to set, which must be in the
     * range [0, 1] or must be the value {@link Float#NaN}, in which case
     * the granularity is cleared
     * @throws IllegalArgumentException if the value is not
     * {@link Float#NaN} and is outside the range [0,1]
     */
    public synchronized void setGranularity(final float granularity) {
        if (granularity != Float.NaN) {
            if (granularity < 0 || 1 < granularity) {
                throw new IllegalArgumentException(
                        "Granularity must be in the range [0,1]: "
                        + granularity);
            }
        }
        this.granularity = granularity;
    }

    /**
     * Sets whether or not the component is inverted.
     * <p>
     * An inverted control essentially flips its endpoints.  In the case of
     * a button 0 becomes 1 and 1 becomes 0; in all other cases, the value
     * is simply multiplied by -1 (-1 becomes 1, and 1 becomes -1).
     * <p>
     * This feature is particularly useful in interfaces that involve vertical
     * movement, such as flight simulators and first-person-shooters;  this
     * can make programs simpler by removing the need for them to check
     * whether the component is inverted or not, and simply rely on this
     * configuration to swap the values for them (such that, for example,
     * "up" would become "down" and "down" would become "up").
     * <p>
     * For information on how inversion, granularity, dead zones and
     * center values interact, please refer to the class-level documentation.
     * 
     * @param isInverted whether or not the component should be inverted
     */
    public synchronized void setInverted(final boolean isInverted) {
        this.isInverted = isInverted;
    }

    /**
     * Sets an optional delay after which turbo mode behavior activates
     * so long as turbo mode is itself enabled.  <strong>If turbo mode
     * is not enabled, this field has no effect.</strong>
     * <p>
     * If the value is zero, then the delay is cleared; in this case,
     * turbo mode will fire a button-pressed event at every poll interval,
     * as usual.
     * <p>
     * If the value is positive then it represents the minimum amount of time
     * that the button must be in a "pressed" state before turbo mode will
     * start firing button-pressed events at every poll interval.  When the
     * button is released, the timer resets; the timer starts again the next
     * time the button is pressed.
     * <p>
     * If the button is currently pressed when this configuration is applied,
     * and the value is a positive integer, the timer starts immediately;
     * if the value is zero, any existing timer is canceled and the
     * turbo behavior is deactivated immediately.  If you subsequently set
     * a positive integer value while the button is <em>still</em> pressed,
     * everything should work as expected (the timer starts immediately again).
     * <p>
     * This behavior is useful in situations involving
     * discrete scrolling or movement, where the fine-grained detail of
     * single button presses is desired as well as the ability to rapidly
     * scroll or move through large swathes of content at a time.
     * <p>
     * Notice that the delay is specified as the <em>minimum</em> time that
     * must elapse.  The only hard guarantee on timing that can be made is
     * that the turbo behavior will start on or before the polling event
     * that occurs immediately after the specified amount of time has elapsed
     * and the button is still in a "pressed" state.  Put another way,
     * the finest precision this value can provide is the precision of the
     * polling interval.
     * 
     * @param turboDelayMillis must be either zero, in which case the
     * delay is cleared, or a positive integer representing the minimum
     * amount of time, in milliseconds, after which turbo mode takes
     * effect after a button pressed event
     */
    public synchronized void setTurboDelayMillis(final long turboDelayMillis) {
        this.turboDelayMillis = turboDelayMillis;
    }

    /**
     * Sets whether or not the component is in turbo mode.
     * <p>
     * When turbo mode is <em>not enabled</em>, a single press of a button
     * generates a single button-pressed event when it is pressed, and a
     * single button-released event when it is released.  When turbo mode
     * <em>is enabled</em>, the button will generate a new button-pressed
     * event every single time that the component is polled, until the button
     * is released (which generates a single button-released event as usual).
     * <p>
     * This is useful for controls in systems where rapid button pushing
     * would be otherwise necessary.  This is particularly common in
     * applications that require repetitive actions, such as "shooters"
     * (e.g., space invaders et al).
     * <p>
     * Turbo mode takes effect immediately; if the button is already
     * pressed, it will start generating new button-pressed events as soon
     * as the configuration has been applied even before it is released.
     * That is, the user doesn't have to release the button before turbo
     * is activated.
     * <p>
     * When used in combination with {@link #setTurboDelayMillis(long)},
     * this can also allow for a combination of fine-grained and mass-event
     * behaviors in a semless, convenient integration.  See
     * {@link #setTurboDelayMillis(long)} for more information.
     * <p>
     * Turbo mode is meaningless for components of type
     * {@link ComponentType#AXIS}.
     * 
     * @param isTurboEnabled whether or not the component should be in
     * turbo mode
     */
    public synchronized void setTurboEnabled(final boolean isTurboEnabled) {
        this.isTurboEnabled = isTurboEnabled;
    }

    /**
     * Sets the user-defined identifier for this component.
     * <p>
     * All events that are dispatched for the component that is associated
     * with this configuration will contain this ID value.
     * <p>
     * <strong>Why is the user defined ID an integer?</strong>
     * Briefly, there are a few reasons for this.  First, it is absolutely
     * not permissible for a mutable object to be used as an ID for thread
     * safety reasons, as the configuration may be accessed by threads
     * internal to this implementation.  Second, the id must be serializable
     * and should, for portability reasons, be unambiguous in its
     * serialization.  Finally, it is undesirable for the ID to be an instance
     * of class whose run-time type might not be available.
     * <p>
     * An integer has all of these properties, can be used in switch,
     * statements, takes up very little space, is easy to format as ASCII
     * text, and is efficient in terms of performing operations.  For these
     * reasons, the user ID is forced to be an integer.
     * <p>
     * For posterity, it should be noted that both enumerations and strings
     * were also considered, and were discarded (enumerations because they
     * might not be present at run-time, strings because they are slow for
     * comparison).
     * 
     * @param userDefinedId the user-defined ID to set.  It is
     * <em>strongly suggested</em> that this value be unique across the
     * entire controller, but this is not enforced by the implementation.
     * The specified ID is provided to all listeners in all events raised
     * by the component associated with this configuration.
     */
    public synchronized void setUserDefinedId(final int userDefinedId) {
        this.userDefinedId = userDefinedId;
    }

    /**
     * Binds a user-defined identifier to a specific value for this component.
     * <p>
     * The value {@link Integer#MIN_VALUE} is reserved and may not be used.
     * All other integer values are valid.
     * <p>
     * This method is (mainly) intended to be used for digtal components.
     * Digital components often emit fixed values that are useful
     * to enumerate and assign logical identifiers to.  For example, a digital
     * directional pad is often thought of as having exactly 8 possible values:
     * North, North-East, East, South-East, South, South-West, West, and
     * North-West; a typical digital button, however, might report these
     * human-intuitive concepts as the values 0.125, 0.250, 0.375, 0.500,
     * 0.625, 0.750, 0.875, and 1.000.  The values never change between runs,
     * and there is never any deviation in the bit pattern of the number
     * returned (that is, the floating point representation is <em>always
     * exactly the same, at a bit-for-bit level</em>).
     * <p>
     * This method binds such a value to an arbitrary value defined by
     * the caller, which can subsequently be used for taking the appropriate
     * action.  For a discussion of why this must be an integer (instead of
     * an enumeration, String, or other user-defined Object), please refer
     * to the documentation of {@link #setUserDefinedId(int)}.
     * <p>
     * Every time that the component is polled, the discovered value is
     * checked against the current bindings.  If there is a user-defined ID
     * bound to the specific value, that user-defined ID is associated with
     * the event that is fired (if any).
     * 
     * @param value the value to bind to a user-defined ID
     * @param id the user-defined ID that should be bound to this value
     * @throws IllegalArgumentException if the specified user ID is
     * {@link Integer#MIN_VALUE}, or if the specified value is outside the
     * range [-1, 1] (these values cannot occur and make no sense to bind)
     */
    public synchronized void setValueId(final float value, final int id)
    {
        if (value < -1.0f || 1.0f < value) {
            throw new IllegalArgumentException(
                    "Value must be in the range [-1.0,1.0]: " + value);
        }
    
        if (id == Integer.MIN_VALUE) {
            throw new IllegalArgumentException(
                    "ID " + Integer.MIN_VALUE + " is reserved and "
                    + "cannot be bound.");
        }
    
        valueIdsByValue.put(value, id);
    }

    /**
     * Loads this partial configuration from Java properties.
     * 
     * @param prefix the prefix to use for retrieving the property keys,
     * which should be the same as when {@link #saveToProperties(String, Map)}
     * was originally called to save the configuration
     * @param source properties to read from
     * @throws ConfigurationException if any of the required keys or values
     * are missing or if any of the values are corrupt
     */
    public synchronized void loadFromProperties(String prefix, Map<String, String> source)
    throws ConfigurationException {
        setUserDefinedId(ConfigurationUtils.getInteger(
                source, prefix + ".userDefinedId"));
        setCenterValueOverride(ConfigurationUtils.getFloat(
                source, prefix + ".centerValue"));
        setDeadZoneLowerBound(ConfigurationUtils.getFloat(
                source, prefix + ".deadZoneLowerBound"));
        setDeadZoneUpperBound(ConfigurationUtils.getFloat(
                source, prefix + ".deadZoneUpperBound"));
        setGranularity(ConfigurationUtils.getFloat(
                source, prefix + ".granularity"));
        setInverted(ConfigurationUtils.getBoolean(
                source, prefix + ".isInverted"));
        setTurboEnabled(ConfigurationUtils.getBoolean(
                source, prefix + ".isTurboEnabled"));
        setTurboDelayMillis(ConfigurationUtils.getLong(
                source, prefix + ".turboDelayMillis"));

        // Read in the property that lists all Float keys for our
        // user-defined symbols table.
        final String userKeysSerializedList = ConfigurationUtils.getString(
                source, prefix + ".userDefinedSymbolKeysList");
        if (userKeysSerializedList != null && userKeysSerializedList.trim().length() > 0) {
            final String[] userKeysSerializedArray = userKeysSerializedList.split(",");
    
            // For each key we found, convert the key back into a IEEE Float and
            // lookup the corresponding (key,value) pair in the properties to
            // find the user-defined symbol value for that key.
            for (final String userKeySerialized : userKeysSerializedArray) {
                final float trueKey = ConfigurationUtils.floatFromHexBitString(userKeySerialized);
                final int trueValue = ConfigurationUtils.getInteger(source, prefix + ".userDefinedSymbolKey." + userKeySerialized);
                valueIdsByValue.put(trueKey, trueValue);
            }
        }
    }
}