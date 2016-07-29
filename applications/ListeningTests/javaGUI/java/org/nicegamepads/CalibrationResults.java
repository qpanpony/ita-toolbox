package org.nicegamepads;

import java.util.Collections;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.Set;

/**
 * Encapsulates the results of a calibration operation.
 * <p>
 * This class is threadsafe and immutable.
 * 
 * @author Andrew Hayden
 */
public final class CalibrationResults
{
    /**
     * All ranges by control.
     */
    private final Map<NiceControl, Range> rangesByControl;

    /**
     * The controller being calibrated.
     */
    private final NiceController controller;

    /**
     * Creates a new immutable and independent results object from the
     * specified builder.
     * 
     * @param builder the builder to use as a source of information
     */
    public CalibrationResults(final CalibrationBuilder builder) {
        this.controller = builder.getController();
        this.rangesByControl = Collections.unmodifiableMap(
                new HashMap<NiceControl, Range>(builder.getRangesByControl()));
    }

    /**
     * Constructs a copy of the specified source.
     * 
     * @param source the source to copy from
     */
    public CalibrationResults(final CalibrationResults source)
    {
        this.controller = source.getController();
        this.rangesByControl = source.getResults();
    }

    /**
     * Returns the range for the specified component.
     * 
     * @param control the control to look up the range for
     * @return the range for the specified control,
     * if any has been recorded; otherwise, <code>null</code>
     */
    public final Range getRange(final NiceControl control)
    {
        return rangesByControl.get(control);
    }

    /**
     * Returns a set of all the controls that currently have ranges
     * in this result.
     * 
     * @return such a set
     */
    public final Set<NiceControl> getComponentsSeen()
    {
        return rangesByControl.keySet();
    }

    /**
     * Returns a map of the controls that currently have ranges of
     * either singularity or non-singularity nature (as specified); the keys
     * are the controls, the values the ranges.
     * <p>
     * Ranges that are singularities represent a mathematical point;
     * that is, <code>low == high</code> and so the size of the range is zero.
     * <p>
     * Ranges that are not singularities have a positive range size,
     * i.e. <code>low != high</code>.
     * 
     * @param singularities whether controls with singularity ranges
     * should be returned
     * @return a map of controls whose ranges are either singularities
     * (if <code>singularities==true</code>) or not
     * (if <code>singularities==false</code>)
     */
    public final Map<NiceControl, Range> getResultsByRangeType(final boolean singularities)
    {
        final Map<NiceControl, Range> results = new HashMap<NiceControl, Range>();
        for (Map.Entry<NiceControl, Range> entry : rangesByControl.entrySet()) {
            final Range range = entry.getValue();
            if (range.isSingularity() == singularities) {
                results.put(entry.getKey(), new Range(range));
            }
        }
        return results;
    }

    /**
     * Returns a list of the controls that currently have ranges
     * where either endpoint is not one of the values in the set {-1,0,1}.
     * <p>
     * Generally speaking most controls are normalized to return maximum
     * and minimum values that are one of the values {-1,0,1}.
     * This method finds controls that don't appear to be behaving in this
     * manner based on the largest and smallest values seen.
     * 
     * @return a map of controls whose ranges appear to be non-standard
     */
    public final Map<NiceControl, Range> getNonStandardResults()
    {
        final Map<NiceControl, Range> results = new HashMap<NiceControl, Range>();
        for (Map.Entry<NiceControl, Range> entry : rangesByControl.entrySet()) {
            final Range range = entry.getValue();
            final float high = range.getHigh();
            final float low = range.getLow();
            if (!((high != 0f  && high != -1f && high != 1f)
                    || (low != 0f  && low != -1f && low != 1f))) {
                results.put(entry.getKey(), new Range(range));
            }
        }
        return results;
    }

    /**
     * Returns all of the results.
     * <p>
     * Each entry in the returned map consists of a component and the range
     * seen for that component.  The returned map is immutable and threadsafe.
     * 
     * @return a copy of the results
     */
    public final Map<NiceControl, Range> getResults()
    {
        return rangesByControl;
    }

    /**
     * The controller being calibrated.
     * 
     * @return the controller being calibrated
     */
    public final NiceController getController()
    {
        return controller;
    }

    @Override
    public final String toString()
    {
        final StringBuilder buffer = new StringBuilder();
        final Map<NiceControl, Range> results = getResults();
        buffer.append(CalibrationResults.class.getName());
        buffer.append(": [");
        buffer.append("controller=");
        buffer.append(controller);
        buffer.append("]\nRanges by component:\n");
        Iterator<Map.Entry<NiceControl, Range>> iterator =
            results.entrySet().iterator();
        while (iterator.hasNext())
        {
            Map.Entry<NiceControl, Range> entry = iterator.next();
            buffer.append("    ");
            buffer.append(entry.getKey());
            buffer.append("=");
            buffer.append(entry.getValue());
            if (iterator.hasNext())
            {
                buffer.append("\n");
            }
        }
        return buffer.toString();
    }
}