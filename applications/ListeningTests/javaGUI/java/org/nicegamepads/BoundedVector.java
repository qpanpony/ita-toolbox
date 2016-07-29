package org.nicegamepads;

/**
 * Container class that defines a true vector with both a directional
 * component as well as a magnitude component.
 * <p>
 * The values contained in this vector are always bounded, thus the
 * name "BoundedVector".  Specifically, the direction will always
 * be in the range [0, 360) and the magnitude will always be in the
 * range [0, {@link #maxMagnitude}].
 * <p>
 * This class is threadsafe and immutable.
 * 
 * @author Andrew Hayden
 */
public class BoundedVector
{
    private final static float MIN_RADIANS = (float) -Math.PI;
    private final static float MAX_RADIANS = (float)  Math.PI;

    /**
     * The direction, expressed as degrees in the range [0, 360) using
     * standard java values (0=east, 90=south, 180=west,
     * -90=north).
     */
    private final float directionJavaDegrees;

    /**
     * The direction, expressed as degrees in the range [0, 360) using
     * standard magnetic compass values (0=north, 90=east, 180=south,
     * 270=west).
     */
    private final float directionCompassDegrees;

    /**
     * The direction, expressed as radians in the range [-1 * pi, pi],
     * using standard java values (0=east, south=pi/2,
     * west=pi, north=-pi/2)
     */
    private final float directionJavaRadians;

    /**
     * The direction, expressed as radians in the range [-1 * pi, pi],
     * using standard magnetic compass values (0=north, east=pi/2,
     * south=pi, west=3pi/2)
     */
    private final float directionCompassRadians;

    /**
     * The magnitude, expressed as percentage of maximum, in the range
     * [0,1].
     */
    private final float magnitude;

    /**
     * For convenience, the easterly component of the overall magnitude.
     * This value is always normalized such that the maximum
     * eastwest-oriented magnitude corresponds to moving east and has
     * the value 1.0, while the minimum eastwest-oriented magnitude
     * corresponds to moving west and has the value -1.0.
     * <p>
     * This is primarily useful for clients that divide movement into
     * its horizontal and vertical components instead of considering it
     * as a true compass heading.
     */
    private final float easterlyComponent;

    /**
     * For convenience, the southerly component of the overall magnitude.
     * This value is always normalized such that the maximum
     * northsouth-oriented magnitude corresponds to moving south and has
     * the value 1.0, while the minimum northsouth-oriented magnitude
     * corresponds to moving north and has the value -1.0.
     * <p>
     * This is primarily useful for clients that divide movement into
     * its horizontal and vertical components instead of considering it
     * as a true compass heading.
     */
    private final float southerlyComponent;

    /**
     * The maximum possible value for the magnitude of this vector.
     */
    private final float maxMagnitude;

    public static class Builder {
        private float directionJavaDegrees = 0f;
        private float directionCompassDegrees = 0f;
        private float directionJavaRadians = 0f;
        private float directionCompassRadians = 0;
        private float magnitude = 0f;
        private float easterlyComponent = 0f;
        private float southerlyComponent = 0f;
        private float maxMagnitude = 0f;
        public float getDirectionJavaDegrees() {
            return directionJavaDegrees;
        }
        public float getDirectionCompassDegrees() {
            return directionCompassDegrees;
        }
        public float getDirectionJavaRadians() {
            return directionJavaRadians;
        }
        public float getDirectionCompassRadians() {
            return directionCompassRadians;
        }
        public float getMagnitude() {
            return magnitude;
        }
        public float getEasterlyComponent() {
            return easterlyComponent;
        }
        public float getSoutherlyComponent() {
            return southerlyComponent;
        }
        public float getMaxMagnitude() {
            return maxMagnitude;
        }

        public void setDirectionJavaDegrees(final float value) {
            if (value < 0 || value >= 360f) {
                throw new IllegalArgumentException("value must be in the range [0, 360): " + value);
            }
            this.directionJavaDegrees = value;
        }
        public void setDirectionCompassDegrees(final float value) {
            if (value < 0 || value >= 360f) {
                throw new IllegalArgumentException("value must be in the range [0, 360): " + value);
            }
            this.directionCompassDegrees = value;
        }
        public void setDirectionJavaRadians(final float value) {
            if (value < MIN_RADIANS || value > MAX_RADIANS) {
                throw new IllegalArgumentException("value must be in the range [" + MIN_RADIANS + "," + MAX_RADIANS +"]: " + value);
            }
            this.directionJavaRadians = value;
        }
        public void setDirectionCompassRadians(final float value) {
            if (value < MIN_RADIANS || value > MAX_RADIANS) {
                throw new IllegalArgumentException("value must be in the range [" + MIN_RADIANS + "," + MAX_RADIANS +"]: " + value);
            }
            this.directionCompassRadians = value;
        }
        public void setMagnitude(final float value) {
            if (value < 0) {
                throw new IllegalArgumentException("value must be >= 0: " + value);
            }
            if (value > maxMagnitude) {
                throw new IllegalArgumentException("value must be less than maxMagnitude, which is currently " + maxMagnitude + ": " + value);
            }
            this.magnitude = value;
        }
        public void setEasterlyComponent(final float value) {
            if (value < -1.0f || value > 1.0f) {
                throw new IllegalArgumentException("value must be in the range [-1,1]): " + value);
            }
            this.easterlyComponent = value;
        }
        public void setSoutherlyComponent(final float value) {
            if (value < -1.0f || value > 1.0f) {
                throw new IllegalArgumentException("value must be in the range [-1,1]): " + value);
            }
            this.southerlyComponent = value;
        }

        public void setMaxMagnitude(final float value) {
            if (value < 0) {
                throw new IllegalArgumentException("value must be >= 0: " + value);
            }
            // force magnitude not to exceed maximum, ever
            magnitude = Math.min(magnitude, maxMagnitude);
            this.maxMagnitude = value;
        }
        public BoundedVector build() {
            return new BoundedVector(this);
        }
    }

    private BoundedVector(Builder builder) {
        this.directionJavaDegrees = builder.getDirectionJavaDegrees();
        this.directionCompassDegrees = builder.getDirectionCompassDegrees();
        this.directionJavaRadians = builder.getDirectionJavaRadians();
        this.directionCompassRadians = builder.getDirectionCompassRadians();
        this.magnitude = builder.getMagnitude();
        this.easterlyComponent = builder.getEasterlyComponent();
        this.southerlyComponent = builder.getSoutherlyComponent();
        this.maxMagnitude = builder.getMaxMagnitude();
    }

    @Override
    public final String toString()
    {
        StringBuilder buffer = new StringBuilder();
        buffer.append(BoundedVector.class.getName());
        buffer.append(" [magnitude=");
        buffer.append(getMagnitude());
        buffer.append(", directionCompassDegrees=");
        buffer.append(getDirectionCompassDegrees());
        buffer.append(", directionCompassRadians=");
        buffer.append(getDirectionCompassRadians());
        buffer.append(", directionJavaDegrees=");
        buffer.append(getDirectionJavaDegrees());
        buffer.append(", directionJavaRadians=");
        buffer.append(getDirectionJavaRadians());
        buffer.append(", easterlyComponent=");
        buffer.append(getEasterlyComponent());
        buffer.append(", southerlyComponent=");
        buffer.append(getSoutherlyComponent());
        buffer.append("]");
        return buffer.toString();
    }

    public float getDirectionJavaDegrees() {
        return directionJavaDegrees;
    }

    public float getDirectionCompassDegrees() {
        return directionCompassDegrees;
    }

    public float getDirectionJavaRadians() {
        return directionJavaRadians;
    }

    public float getDirectionCompassRadians() {
        return directionCompassRadians;
    }

    public float getMagnitude() {
        return magnitude;
    }

    public float getEasterlyComponent() {
        return easterlyComponent;
    }

    public float getSoutherlyComponent() {
        return southerlyComponent;
    }

    public float getMaxMagnitude() {
        return maxMagnitude;
    }
}