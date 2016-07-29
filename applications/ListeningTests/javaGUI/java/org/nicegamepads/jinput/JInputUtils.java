package org.nicegamepads.jinput;

import net.java.games.input.Component;

public class JInputUtils {
    /**
     * Given a JInput component, gets its dead zone and returns a sanitized
     * version of it.
     * <p>
     * If the component does not have a dead zone, this method returns
     * {@link Float#NaN}.  Otherwise, the method takes the deadzone value
     * returns and converts it to ab absolute value, then clamps it into the
     * range [0,1].
     * 
     * @return as described above
     */
    public final static float getDeadZone(final Component jinputComponent)
    {
        float deadZone = jinputComponent.getDeadZone();
        if (!Float.isNaN(deadZone) && !Float.isInfinite(deadZone)) {
            // Valid float found.
            // We only care about the absolute value; kill negatives.
            deadZone = Math.abs(deadZone);
            // Sanity check, clamp to range [0,1]
            deadZone = Math.min(deadZone, 1.0f);
            return deadZone;
        }
        return Float.NaN;
    }
}
