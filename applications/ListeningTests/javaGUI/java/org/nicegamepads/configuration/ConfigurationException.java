package org.nicegamepads.configuration;

/**
 * An exception representing a generic configuration error.
 *
 * @author Andrew Hayden
 */
@SuppressWarnings("serial")
public class ConfigurationException extends RuntimeException {
    public ConfigurationException() { super(); }
    public ConfigurationException(String message, Throwable cause) { super(message, cause); }
    public ConfigurationException(String message) { super(message); }
    public ConfigurationException(Throwable cause) { super(cause); }
}