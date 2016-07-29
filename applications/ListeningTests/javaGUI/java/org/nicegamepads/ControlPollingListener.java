package org.nicegamepads;

/**
 * Interface for entities wishing to be notified about every single polling
 * event that occurs for a control.
 * <p>
 * This is the finest possible level of listener.  These listeners should
 * expect to be invoked every single time a polling interval elapses,
 * regardless of whether or not the value of the control has changed.
 * 
 * @author Andrew Hayden
 */
public interface ControlPollingListener
{
    /**
     * Invoked every time a control is polled.
     * 
     * @param event event details
     */
    public abstract void controlPolled(ControlEvent event);
}
