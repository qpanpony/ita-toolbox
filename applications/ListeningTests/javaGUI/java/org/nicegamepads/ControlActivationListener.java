package org.nicegamepads;

import org.nicegamepads.configuration.ControlConfiguration;

/**
 * Interface for entities wishing to be notified when a control is
 * activated or deactivated.
 * <p>
 * A control becomes "activated" whenever its value becomes equal to one
 * of the values bound to the associated {@link ControlConfiguration}.
 * A control becomes "deactivated" whenever its value ceases to be equal
 * to such a value.
 * If a control moves from one bound value to another in a single polling
 * interval, two events should be fired (one for the deactivation of the
 * control at its previous value, and one for the activation of the
 * control at its new value).
 * 
 * @author Andrew Hayden
 */
public interface ControlActivationListener
{
    /**
     * Invoked whenever a control becomes activated.  A control becomes
     * activated when its value becomes equal to one of the values bound
     * in the associated {@link ControlConfiguration}.
     * <p>
     * In this case the field {@link ControlEvent#currentValueId} contains
     * the id of the previously-active value.
     * 
     * @param event the event details
     */
    public abstract void controlActivated(ControlEvent event);

    /**
     * Invoked whenever a control becomes deactivated.  A control becomes
     * deactivated when its value is no longer equal to one of the values bound
     * in the associated {@link ControlConfiguration}.
     * <p>
     * In this case the field {@link ControlEvent#previousValueId} contains
     * the id of the previously-active value.
     * 
     * @param event the event details
     */
    public abstract void controlDeactivated(ControlEvent event);
}
