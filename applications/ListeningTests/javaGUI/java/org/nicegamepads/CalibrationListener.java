package org.nicegamepads;

/**
 * Interface for entities wishing to be notified about calibration events.
 * 
 * @author Andrew Hayden
 */
public interface CalibrationListener
{
    /**
     * Invoked when calibration is started.
     * 
     * @param controller the controller being calibrated
     */
    public abstract void calibrationStarted(NiceController controller);

    /**
     * Invoked when calibration is stopped.
     * 
     * @param controller the controller being calibrated
     * @param results the current results
     */
    public abstract void calibrationStopped(NiceController controller,
            CalibrationResults results);

    /**
     * Invoked when calibration results are updated.  Results are updated
     * in near-realtime as new values are discovered from a control.
     * 
     * @param controller the controller being calibrated
     * @param control the control whose range has been updated
     * @param range the new range
     */
    public abstract void calibrationResultsUpdated(NiceController controller,
            NiceControl control, Range range);
}
