package org.nicegamepads.configuration;

import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import org.nicegamepads.NiceControl;
import org.nicegamepads.NiceControlType;
import org.nicegamepads.NiceController;
import org.nicegamepads.jinput.JInputUtils;

/**
 * Builder to generate a {@link ControllerConfiguration}.  See that class for all
 * the various details about what each field means, etceteras.
 * <p>
 * This class is threadsafe.
 * 
 * @author ahayden
 */
public class ControllerConfigurationBuilder {
    /**
     * Configurations for each control in the controller.
     * <p>
     * This is explicitly a linked hash map to make it known that insertion
     * order is preserved and that null values are allowed.
     */
    private LinkedHashMap<NiceControl, ControlConfigurationBuilder> buildersByControl;

    /**
     * The controller that this configuration was generated for.
     */
    private final NiceController controller;

    public ControllerConfigurationBuilder(final NiceController controller) {
        this.controller = controller;
        // Fill in config info for controls
        final List<NiceControl> controls = controller.getControls();
        final int numControls = controls.size();
        buildersByControl = new LinkedHashMap<NiceControl, ControlConfigurationBuilder>(numControls);
        for (final NiceControl control : controls) {
            buildersByControl.put(control, (new ControlConfigurationBuilder(control)));
        }
        loadDeadZoneDefaults();
    }

    /**
     * @return a new {@link ControllerConfiguration} containing the information
     * represented in this builder
     */
    public synchronized ControllerConfiguration build() {
        return new ControllerConfiguration(this);
    }

    /**
     * Returns the controller that this configuration was created for.
     * 
     * @return the controller that this configuration was created for.
     */
    public NiceController getController() {
        return controller;
    }

    /**
     * Returns the configuration builder for the specified control.
     * <p>
     * Note that this method will throw a {@link ConfigurationException} if
     * the caller attempts to find a configuration to a nonexistent control.
     * Strictly speaking, no harm would be done by doing so - but if the caller
     * is trying to find to a nonexistent control, then a serious logic
     * error has probably occurred on the calling side.
     * 
     * @param control the control to retrieve the configuration builder for
     * @return the configuration builder for the specified control, if the
     * control exists in this configuration; otherwise, <code>null</code>
     */
    public synchronized ControlConfigurationBuilder getConfigurationBuilder(final NiceControl control)
    throws ConfigurationException {
        final ControlConfigurationBuilder builder = buildersByControl.get(control);
        if (builder == null) {
            throw new ConfigurationException("No such control in this configuration.");
        }
        return builder;
    }

    /**
     * @return the map of all configuration builders present; the order of
     * this map is guaranteed to be the same as the order in which the
     * controls are enumerated in the controller
     */
    public synchronized Map<NiceControl, ControlConfigurationBuilder> getConfigurationBuilders() {
        return buildersByControl;
    }

    /**
     * Loads a new configuration from Java properties.
     * <p>
     * All internal configuration objects are created anew, meaning that any
     * outstanding configuration objects are now orphaned (that is, the
     * configurations for each control are created fresh, and the references
     * to the old ones are discarded).
     * 
     * @param prefix the prefix to use for retrieving the property keys,
     * which should be the same as when {@link #saveToMap(String, Map)}
     * If <code>null</code> or an empty string, no prefix is used; otherwise,
     * the specified prefix is assumed to be prepended to all values.
     * If the prefix does not end with a ".", a "." is automatically appended
     * for performing the lookups.
     * was originally called to save the configuration
     * @param source properties to read from
     * @throws ConfigurationException if any of the required keys or values
     * are missing or if any of the values are corrupt
     */
    public synchronized void loadFromMap(String prefix, Map<String, String> source)
    throws ConfigurationException {
        // Check prefix and amend as necessary
        if (prefix != null && prefix.length() > 0) {
            if (!prefix.endsWith(".")) {
                prefix = prefix + ".";
            }
        } else {
            prefix = "";
        }

        final int numControls = ConfigurationUtils.getInteger(source, prefix + "numControls");

        // Read all controls
        final Iterator<NiceControl> controlIterator = buildersByControl.keySet().iterator();
        for (int x=0; x<numControls; x++) {
            final NiceControl control = controlIterator.next();
            // Notice that order is preserved by the
            // "controlConfigurations" collection, so that our integer
            // mappings here will always be the same every single time
            // and will stay in-sync.
            ControlConfigurationBuilder config =
                new ControlConfigurationBuilder(control);
            config.loadFromProperties(
                    prefix + "control" + x, source);
            buildersByControl.put(control, config);
        }
    }

    /**
     * Loads all the settings from the specified configuration into this
     * configuration.  This method can be used to copy settings between
     * different controllers so long as their fingerprints are identical.
     * 
     * @param other the source object to copy settings from
     * @throws ConfigurationException if the specified other configuration
     * has a different fingerprint than this controller
     */
    public synchronized void loadFrom(final ControllerConfiguration other) {
        final int fingerprint = getController().getFingerprint();
        final int otherFingerprint = other.getController().getFingerprint();
        if (otherFingerprint != fingerprint) {
            throw new ConfigurationException(
                    "Specified source configuration has fingerprint "
                    + otherFingerprint
                    + ", which does not match the destination fingerprint "
                    + fingerprint);
        }

        // Need to translate into a map and load the map, because we
        // may not have references to the same objects.
        final Map<String, String> otherConfigAsMap = other.saveToMap("internal");
        loadFromMap("internal", otherConfigAsMap);
    }

    /**
     * Convenience method to set the specified granularity for all of the
     * controller's analog controls.
     * <p>
     * This is useful for sensitive controllers that provide more values
     * than your application can reasonably make use of, and as a result
     * flood the system with value-changed events that are of little or
     * no real consequence (e.g., value change from 0.0001 to 0.0002).
     * Generally, even a small granularity such as 0.2 will greatly
     * reduce the number of spurious value-changed events encountered.  For
     * example, a granularity of 0.2 splits the logical range of an analog
     * control into 10 logical "buckets", 5 on each side of 0 (e.g.,
     * left and right each have 5 "buckets").
     * <p>
     * Different controllers may vary significantly in this regard, so some
     * experimentation may be necessary.
     * <p>
     * Note that the values are constrained by the requirements set forth
     * in {@link ControlConfiguration#setGranularity(float)}.
     * <p>
     * This method is equivalent to finding all analog controls in
     * a controller and invoking
     * {@link ControlConfiguration#setGranularity(float)}
     * for each such control.
     * 
     * @param granularity see
     * {@link ControlConfiguration#setGranularity(float)}
     */
    public synchronized void setAllAnalogGranularities(float granularity)
    {
        final List<NiceControl> eligibleControls =
            getController().getControlsByType(NiceControlType.CONTINUOUS_INPUT);
        for (final NiceControl control : eligibleControls) {
            getConfigurationBuilder(control).setGranularity(granularity);
        }
    }

    /**
     * Convenience method to (re)load the default dead zones for all of the
     * controller's controls.
     */
    public synchronized void loadDeadZoneDefaults()
    {
        for (final NiceControl control : getController().getControls()) {
            final float deadZone = JInputUtils.getDeadZone(control.getJinputComponent());
            if (Float.isNaN(deadZone)) {
                getConfigurationBuilder(control).setDeadZoneBounds(deadZone, deadZone);
            } else {
                getConfigurationBuilder(control).setDeadZoneBounds(-deadZone, deadZone);
            }
        }
    }

    /**
     * Convenience method to set the specified dead zones for all of the
     * controller's analog controls.
     * <p>
     * This is useful for hyper-sensitive controllers that don't report
     * reasonable dead zones.  A small range such as
     * <code>[-0.05f, 0.05f]</code> (that is, 5% of the total range)
     * is usually a good choice, as it will generally compensate for random
     * jitter without making the device feel unresponsive.  Different
     * controllers may vary significantly in this regard, however, so some
     * experimentation may be necessary.
     * <p>
     * Note that the bounds are constrained by the requirements set forth
     * in {@link ControlConfiguration#setDeadZoneBounds(float, float)}.
     * <p>
     * This method is equivalent to finding all analog controls in
     * a controller and invoking
     * {@link ControlConfiguration#setDeadZoneBounds(float, float)}
     * for each such control.
     * 
     * @param lowerBound see
     * {@link ControlConfiguration#setDeadZoneBounds(float, float)
     * @param upperBound see
     * {@link ControlConfiguration#setDeadZoneBounds(float, float)
     */
    public synchronized void setAllAnalogDeadZones(final float lowerBound, final float upperBound)
    {
        final List<NiceControl> eligibleControls =
            getController().getControlsByType(NiceControlType.CONTINUOUS_INPUT);
        for (final NiceControl control : eligibleControls) {
            getConfigurationBuilder(control).setDeadZoneBounds(lowerBound, upperBound);
        }
    }
}