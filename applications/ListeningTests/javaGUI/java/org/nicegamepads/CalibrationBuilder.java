package org.nicegamepads;

import java.util.HashMap;
import java.util.Map;

/**
 * Utility class used to build up calibration results in real time.
 * <p>
 * This class is threadsafe.
 * 
 * @author ahayden
 */
public class CalibrationBuilder {
    /**
     * The controller for which calibration is being built.
     */
    private final NiceController controller;

    /**
     * The ranges discovered for each control.
     */
    private final Map<NiceControl, Range> rangesByControl;

    /**
     * Creates a new builder to accumulate calibration data for the specified
     * controller.
     * 
     * @param controller the controller to build calibration for
     */
    public CalibrationBuilder (final NiceController controller) {
        this.controller = controller;
        rangesByControl = new HashMap<NiceControl, Range>();
    }

    /**
     * Processes a value and updates the appropriate range as necessary.
     * 
     * @param control the control from which the value was recorded
     * @param value the value recorded; infinities and floats that are
     * representations of non-a-number (NaN) are ignored
     * @return <code>true</code> if a range was created or updated as a
     * result of this operation; otherwise, <code>false</code>
     */
    public synchronized boolean processValue(final NiceControl control, float value)
    {
        // Cannot process infinite or NaN values
        if (Float.isInfinite(value) || Float.isNaN(value))
        {
            return false;
        }

        final boolean updated;
        Range range = getRangesByControl().get(control);
        if (range == null)
        {
            getRangesByControl().put(control, new Range(value, value));
            updated = true;
        }
        else
        {
            if (value < range.getLow()) {
                getRangesByControl().put(control, new Range(value, range.getHigh()));
                updated = true;
            }
            else if (value > range.getHigh()) {
                getRangesByControl().put(control, new Range(range.getLow(), value));
                updated = true;
            } else {
                updated = false;
            }
        }
        return updated;
    }

    /**
     * Returns the range for the specified component.
     * 
     * @param control the control to look up the range for
     * @return the range for the specified control,
     * if any has been recorded; otherwise, <code>null</code>
     */
    public synchronized Range getRange(final NiceControl control) {
        return getRangesByControl().get(control);
    }

    /**
     * @return a new {@link CalibrationResults} having the state
     * currently contained in this builder.
     */
    public synchronized CalibrationResults build() {
        return new CalibrationResults(this);
    }

    /**
     * @return the controller for which calibration is being built
     */
    public NiceController getController() {
        return controller;
    }

    /**
     * @return the current map of controls to ranges
     */
    public synchronized Map<NiceControl, Range> getRangesByControl() {
        return rangesByControl;
    }
}