package org.nicegamepads;

/**
 * Simple container for a range.
 * <p>
 * This class is threadsafe and immutable.
 * 
 * @author Andrew Hayden
 */
public final class Range
{
    /**
     * Low value of the range.
     */
    private final float low;

    /**
     * High value of the range.
     */
    private final float high;

    /**
     * Constructs a new range with the specified values.
     * 
     * @param low the low value
     * @param high the high value
     */
    public Range(final float low, final float high)
    {
        this.low = low;
        this.high = high;
    }

    /**
     * Copies another range.
     * 
     * @param source the range to copy from
     */
    public Range(final Range source)
    {
        this(source.getLow(), source.getHigh());
    }

    @Override
    public final String toString()
    {
        return Range.class.getName()
            + ": [" + low + "," + high + "]";
    }

    /**
     * @return the low value of the range
     */
    public float getLow() {
        return low;
    }

    /**
     * @return the high value of the range
     */
    public float getHigh() {
        return high;
    }

    /**
     * @return <code>true</code> if and only if the range represents a
     * singularity (where the low and high values are equal).
     */
    public boolean isSingularity() {
        return low == high;
    }

    /**
     * @return the size of the range, for convenience, calculated as
     * <code>Math.abs(high - low)</code>.
     */
    public float getSize() {
        return Math.abs(high - low);
    }
}