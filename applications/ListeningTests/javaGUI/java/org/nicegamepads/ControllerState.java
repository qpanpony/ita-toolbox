package org.nicegamepads;

import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Encapsulates the state of a controller.
 * 
 * @author Andrew Hayden
 */
public final class ControllerState
{
    /**
     * All of the control states associated with this controller state,
     * possibly recursively expanded (according to the constructor parameters
     * provided)
     */
    final ControlState[] controlStates;

    /**
     * The controller whose state this is.
     */
    final NiceController controller;

    /**
     * Lazily-initialized mapping of states by their controls.
     */
    private final Map<NiceControl, ControlState> statesByControl;

    /**
     * The last time at which this controller state was completely refreshed,
     * in milliseconds since the epoch.
     */
    volatile long timestamp = -1L;

    /**
     * Constructs a new controller state for the specified controller.
     * 
     * @param configuration the configuration to create state for
     */
    ControllerState(NiceController controller)
    {
        this.controller = controller;
        List<NiceControl> allControls = controller.getControls();

        // Create control states.
        controlStates = new ControlState[allControls.size()];
        Map<NiceControl, ControlState> tempMap =
            new HashMap<NiceControl, ControlState>();
        int index = 0;
        for (NiceControl control : allControls)
        {
            controlStates[index] = new ControlState(control);
            tempMap.put(control, controlStates[index]);
            index++;
        }
        statesByControl = Collections.unmodifiableMap(tempMap);
    }

    /**
     * Constructs an independent copy of the specified source object.
     * <p>
     * This method creates a deep copy.  It is entirely independent of the
     * source in all respects.
     * 
     * @param source the source to copy from
     */
    ControllerState(ControllerState source)
    {
        this.controller = source.controller;
        timestamp = source.timestamp;
        controlStates = new ControlState[source.controlStates.length];
        Map<NiceControl, ControlState> tempMap =
            new HashMap<NiceControl, ControlState>();
        for (int index=0; index<controlStates.length; index++)
        {
            controlStates[index] =
                new ControlState(source.controlStates[index]);
            tempMap.put(
                    controlStates[index].control, controlStates[index]);
        }
        statesByControl = Collections.unmodifiableMap(tempMap);
    }

    /**
     * Returns the state for the specified control within this controller
     * state.
     * 
     * @param control the control whose state should be retrieved
     * @return the state of the control
     * @throws NoSuchControlException if the specified control is not
     * part of the controller associated with this state
     */
    public final ControlState getControlState(NiceControl control)
    {
        ControlState state = statesByControl.get(control);
        if (state == null)
        {
            throw new NoSuchControlException(
                    "Control does not exist in the controller "
                    + "associated with this state.");
        }
        return state;
    }

    /**
     * Returns the last time at which this controller state was completely
     * refreshed, in milliseconds since the epoch.
     * 
     * @return the time
     */
    public final long getTimestamp()
    {
        return timestamp;
    }
}