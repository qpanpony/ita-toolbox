package org.nicegamepads.configuration;

import java.util.Collections;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.Map;

import org.nicegamepads.NiceControl;
import org.nicegamepads.NiceController;

/**
 * Represents the configuration for a controller.
 * <p>
 * This class is threadsafe and immutable.
 * 
 * @author Andrew Hayden
 */
public class ControllerConfiguration
{
    /**
     * Configurations for each control in the controller.
     * <p>
     * This is actually a linked hash map to make it known that insertion
     * order is preserved and that null values are allowed.
     */
    private final Map<NiceControl, ControlConfiguration> controlConfigurations;

    /**
     * The controller that this configuration was generated for.
     */
    private final NiceController controller;

    /**
     * Creates a configuration compatible with, but not specifically tied to,
     * the specified instance of controller.
     * <p>
     * The controller is used solely for determining the various attributes
     * that need to be persisted.  That is, it is used primarily for
     * examination of hardware.  A unique fingerprint for the controller is
     * inferred and kept as a sanity check for loading the configuration
     * in the future.
     * 
     * @param controller the controller to create a compatible configuration for
     */
    public ControllerConfiguration(final ControllerConfigurationBuilder builder) {
        this.controller = builder.getController();
        final Map<NiceControl, ControlConfiguration> configurations = new LinkedHashMap<NiceControl, ControlConfiguration>();
        for (Map.Entry<NiceControl, ControlConfigurationBuilder> builderEntry : builder.getConfigurationBuilders().entrySet()) {
            configurations.put(builderEntry.getKey(), builderEntry.getValue().build());
        }
        this.controlConfigurations = Collections.unmodifiableMap(configurations);
    }

    /**
     * Saves this configuration to a mapping of (key,value) pairs
     * in an unambiguous manner suitable for user in a Java properties file.
     * <p>
     * The specified prefix, possibly with an added trailing "." character, is
     * prepended to the names of all properties written by this method.
     * <p>
     * This is a convenience method to call {@link #saveToMap(String, Map)}
     * with a <code>null</code> map, which causes that method to generate
     * and return a new map.
     * 
     * @param prefix the prefix to use for creating the property keys.
     * If <code>null</code> or an empty string, no prefix is set; otherwise,
     * the specified prefix is prepended to all values.  If the prefix does
     * not end with a ".", a "." is automatically inserted between the prefix
     * and the values.
     * @return a new {@link Map} containing this configuration's
     * (key,value) pairs
     */
    final Map<String, String> saveToMap(final String prefix) {
        return saveToMap(prefix, null);
    }

    /**
     * Saves this configuration to a mapping of (key,value) pairs
     * in an unambiguous manner suitable for user in a Java properties file.
     * <p>
     * The specified prefix, possibly with an added trailing "." character, is
     * prepended to the names of all properties written by this method.
     * 
     * @param prefix the prefix to use for creating the property keys.
     * If <code>null</code> or an empty string, no prefix is set; otherwise,
     * the specified prefix is prepended to all values.  If the prefix does
     * not end with a ".", a "." is automatically inserted between the prefix
     * and the values.
     * @param destination optionally, a map into which the properties should
     * be written; if <code>null</code>, a new map is created and returned.
     * Any existing entries with the same names are overwritten.
     * @return if <code>destination</code> was specified, the reference to
     * that same object (which now contains this configuration's (key,value)
     * pairs); otherwise, a new {@link Map} containing this configuration's
     * (key,value) pairs
     */
    final Map<String, String> saveToMap(String prefix, Map<String,String> destination) {
        if (destination == null) {
            destination = new HashMap<String, String>();
        }

        // Check prefix and amend as necessary
        if (prefix != null && prefix.length() > 0) {
            if (!prefix.endsWith(".")) {
                prefix = prefix + ".";
            }
        } else {
            prefix = "";
        }

        destination.put(prefix + "numControls", Integer.toString(controlConfigurations.size()));
        destination.put(prefix + "controllerFingerprint", Integer.toString(controller.getFingerprint()));

        // Write out all controls.
        int counter = 0;
        for (ControlConfiguration config : controlConfigurations.values()) {
            config.saveToProperties(prefix + "control" + counter, destination);
            counter++;
        }

        return destination;
    }

    /**
     * Returns the configuration for the specified control.
     * <p>
     * Note that this method will throw a {@link ConfigurationException} if
     * the caller attempts to find a configuration to a nonexistent control.
     * Strictly speaking, no harm would be done by doing so - but if the caller
     * is trying to find to a nonexistent control, then a serious logic
     * error has probably occurred on the calling side.
     * 
     * @param control the control to retrieve the configuration for
     * @return the configuration for the specified control, if the
     * control exists in this configuration; otherwise, <code>null</code>
     */
    public ControlConfiguration getConfiguration(NiceControl control)
    throws ConfigurationException {
        final ControlConfiguration config = controlConfigurations.get(control);
        if (config == null) {
            throw new ConfigurationException("No such control in this configuration.");
        }
        return config;
    }

    @Override
    public String toString() {
        StringBuilder buffer = new StringBuilder();
        return toStringHelper(this, buffer, "");
    }

    /**
     * Recursively creates a string description of this object.
     * 
     * @param configuration the configuration to process recursively
     * @param buffer the buffer to append to
     * @param prefix prefix to place in front of each line
     * @return the string
     */
    private final static String toStringHelper(
            ControllerConfiguration configuration,
            StringBuilder buffer, String prefix) {
        buffer.append(prefix);
        buffer.append(ControllerConfiguration.class.getName());
        buffer.append(": ");
        buffer.append("controller=");
        buffer.append(configuration.controller);
        buffer.append("\n");
        buffer.append(prefix);
        buffer.append("Control Configurations:\n");
        for (Map.Entry<NiceControl, ControlConfiguration> entry :
            configuration.controlConfigurations.entrySet()) {
            buffer.append(prefix);
            buffer.append("    ");
            buffer.append(entry.getKey());
            buffer.append("=");
            buffer.append(entry.getValue());
            buffer.append("\n");
        }
        return buffer.toString();
    }

    /**
     * Returns the controller that this configuration was created for.
     * 
     * @return the controller that this configuration was created for.
     */
    public NiceController getController() {
        return controller;
    }
}