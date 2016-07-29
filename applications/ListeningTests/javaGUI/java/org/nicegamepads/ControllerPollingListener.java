package org.nicegamepads;

/**
 * Interface for entities wishing to be notified about every single polling
 * event that occurs for a controller.
 * <p>
 * This method of listening presents an opportunity to consider the state of
 * all the components in the controller at once instead of considering each
 * component separately.  This is particularly useful if the application
 * needs to combine the information from multiple components into an
 * aggregate object.
 * <p>
 * There are two primary ways of using this listener: in lieu of listening
 * to individual components, or as notification that all components have
 * reported their values and that it is now safe to perform any aggregation
 * operations and provide them to downstream consumers with confidence
 * that all values obtained during the polling interval are associated with
 * that one interval.
 * 
 * @author Andrew Hayden
 */
public interface ControllerPollingListener
{
    /**
     * Invoked whenever the controller is polled.
     * 
     * @param controllerState the state of the controller as it was when
     * polling completed
     */
    public abstract void controllerPolled(ControllerState controllerState);
}
