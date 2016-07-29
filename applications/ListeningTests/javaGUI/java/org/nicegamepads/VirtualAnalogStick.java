package org.nicegamepads;


/**
 * Represents the usual end-user conception of an analog stick by combining
 * the inputs of two axes - a left-right and a top-bottom - into a single
 * logical entity.
 * <p>
 * <strong>Important:</strong> this class supports two different kinds of
 * virtual analog sticks: {@link PhysicalConstraints#CIRCULAR} and
 * {@link PhysicalConstraints#UNCONSTRAINED}.  The {@link BoundedVector}
 * objects returned by the methods
 * {@link #process(ControllerState, BoundedVector)}
 * and
 * {@link #process(float, float, BoundedVector)}
 * both operate on either kind of virtual analog stick, but with an important
 * caveat: virtual sticks of the kind {@link PhysicalConstraints#UNCONSTRAINED}
 * have a different range in their magnitudes.  This is because the concept of
 * magnitude does not map quite the same to such a controller; since each stick
 * can move in an unconstrained manner, the maximum magnitude varies
 * as a sinusoidal function of the distance from the center of the individual
 * controls - whereas with a circular control, the maximum magnitude is
 * always 1.0 (that being the radius of the circle in which the control is
 * constrained).
 * <p>
 * Let us consider an example.  If you push the stick straight "south",
 * then the north-south control achieves the value 1.0 and the magnitude
 * would be 1.0.  However, if you also push the stick as far "east" as
 * possible, the stick will move to the south-east corner of its range and
 * the east-west control will also achieve the value 1.0.  Since the values
 * of both controls are 1.0, the magnitude of the resulting vector is
 * <code>Math.sqrt(Math.pow(1,2) + Math.pow(1,2))</code>, which is simply
 * the square root of 2 (~1.414).
 * 
 * @author Andrew Hayden
 */
public class VirtualAnalogStick
{
    /**
     * Possible kinds of physical constraints this analog stick can represent.
     */
    public static enum PhysicalConstraints
    {
        /**
         * Represents an unconstrained physical model in which the axes can
         * move independently and can both achieve their maxima simultaneously.
         * <p>
         * This can be visualized as the control being within a box, where
         * the control can reach any of the four corners of the box (at
         * each corner each axis achieves either a minimum or a maximum value).
         * <p>
         * This model of control is much less common than
         * the {@link #CIRCULAR} model in the world of gamepads.
         */
        UNCONSTRAINED,

        /**
         * Represents a circular constraint physical model in which the
         * axes are bound by a circle.  In such a model, the physical bounds
         * of the circle constrain the values that can be physically achieved
         * by the axes.  For example, if the controls are moved to the
         * "3 o'clock" position on the circle (i.e., northeast), the values
         * of the axes cannot exceed the square root of 2, being both
         * the sin and cosign of a 45-degree angle.
         * <p>
         * This can be visualized as the control being within a circle
         * that is inscirbed within a rectangle, with the north, south,
         * east and west points of the circle being tangent to the sides
         * of the rectangle.  In this model, the control can reach the
         * eastern edge of the box at only a signle point - the point that
         * lies on the circumference of the circle at exactly due-east.
         * If the control moves slightly north, it must necessarily move
         * slightly west since it cannot escape the bounds of the circle.
         * <p>
         * This model of control is much more common than
         * the {@link #UNCONSTRAINED} model in the world of gamepads.
         */
        CIRCULAR;
    }

    /**
     * An approximation of the square root of 2.
     */
    private final static float ROOT2 = (float) Math.sqrt(2d);

    /**
     * Physical constraints.
     */
    private final PhysicalConstraints constraints;

    /**
     * The horizontal control.
     */
    private final NiceControl eastWestControl;

    /**
     * The vertical control.
     */
    private final NiceControl northSouthControl;

    /**
     * The orientation of the horizontal control.
     */
    private final HorizontalOrientation eastWestOrientation;

    /**
     * The orientation of the vertical control.
     */
    private final VerticalOrientation northSouthOrientation;

    /**
     * Constructs a new virtual analog stick with the specified parameters.
     * 
     * @param constraints the constraints that define what kind of
     * virtual analog stick this is.
     * @param eastWestControl the control that provides the east-west
     * portion of the vector
     * @param northSouthControl the control that provides the north-south
     * portion of the vector
     * @param eastWestOrientation the orientation of the east-west control
     * (i.e., which direction is positive and which is negative)
     * @param northSouthOrientation the orientation of the north-south control
     * (i.e., which direction is positive and which is negative)
     */
    public VirtualAnalogStick(PhysicalConstraints constraints,
            NiceControl eastWestControl, NiceControl northSouthControl,
            HorizontalOrientation eastWestOrientation,
            VerticalOrientation northSouthOrientation)
    {
        this.constraints = constraints;
        this.eastWestControl = eastWestControl;
        this.northSouthControl = northSouthControl;
        this.eastWestOrientation = eastWestOrientation;
        this.northSouthOrientation = northSouthOrientation;
    }

    /**
     * Processes the specified controller state and derives a
     * {@link BoundedVector} representing the position of this virtual
     * analog stick.
     * 
     * @param state the state to process
     * @return a {@link BoundedVector} containing the result
     */
    public final BoundedVector process(ControllerState state)
    {
        return calculate(constraints,
                eastWestOrientation,
                state.getControlState(eastWestControl).getCurrentValue(),
                northSouthOrientation,
                state.getControlState(northSouthControl).getCurrentValue());
    }

    /**
     * Processes the specified east-west and north-south values as if they
     * had been generated from the controls associated with this
     * virtual analog stick and derives a {@link BoundedVector} representing
     * the position of this virtual analog stick.
     * 
     * @param eastWestValue the value to consider as that of the east-west
     * control
     * @param northSouthValue the value to consider as that of the north-south
     * control
     * @return a {@link BoundedVector} containing the result
     */
    public final BoundedVector process(final float eastWestValue, final float northSouthValue)
    {
        return calculate(constraints,
                eastWestOrientation, eastWestValue,
                northSouthOrientation, northSouthValue);
    }

    final static BoundedVector calculate(
            PhysicalConstraints physicalConstraints,
            HorizontalOrientation horizontalOrientation, float horizontalValue,
            VerticalOrientation verticalOrientation, float verticalValue)
    {
        BoundedVector.Builder builder = new BoundedVector.Builder();

        // In general, most of the time the control is at rest and we can
        // short-circuit that case here.
        if (horizontalValue == 0f && verticalValue == 0f)
        {
            builder.setDirectionCompassDegrees(0f);
            builder.setDirectionCompassRadians(0f);
            builder.setDirectionJavaDegrees(90f);
            builder.setDirectionJavaRadians((float) (Math.PI / 2d));
            builder.setEasterlyComponent(0f);
            builder.setSoutherlyComponent(0f);
            builder.setMagnitude(0f);
            return builder.build();
        }

        // Otherwise, we have to do all the calculations...

        if (horizontalOrientation == HorizontalOrientation.EAST_POSITIVE)
        {
            builder.setEasterlyComponent(horizontalValue);
        }
        else
        {
            builder.setEasterlyComponent(-1f * horizontalValue);
        }

        if (verticalOrientation == VerticalOrientation.SOUTH_POSITIVE)
        {
            builder.setSoutherlyComponent(verticalValue);
        }
        else
        {
            builder.setSoutherlyComponent(-1f * verticalValue);
        }

        // Calculate degrees and radians
        builder.setDirectionJavaRadians((float)
            Math.atan2(verticalValue, horizontalValue));

        builder.setDirectionJavaDegrees((float)
            Math.toDegrees(builder.getDirectionJavaRadians()));
        
        // Java is based on a compass where east is 0 and values increase
        // clockwise.  The magnetic compass is based on north 0 and also
        // increasing clockwise.  So to get from Java to compass, we
        // need to offset by -90 degrees or -(pi/2)
        float compassDegrees = builder.getDirectionJavaDegrees() + 90f;
        if (compassDegrees < 0) {
            compassDegrees += 360f;
        }
        builder.setDirectionCompassDegrees(compassDegrees);
        
        float compassRadians = (float) (Math.toRadians(builder.getDirectionJavaDegrees()) - (Math.PI / 2d));
        if (compassRadians < 0) {
            compassRadians += Math.PI * 2d;
        }
        builder.setDirectionCompassRadians(compassRadians);

        // In all cases, we can consider the two values as forming the
        // endpoints of two edges of a right triangle whose right angle
        // is centered at the origin.  So we can use either the distance
        // formula or the hypotenuse formula (equivalent here) to calculate
        // the vector represented by the two axes.
        //
        // In the case of a circular constraint, the axes do not truly
        // move independently since east-west motion away from the center
        // reduces the range of motion of the north-south control (and
        // vice-versa).  The sinusoidal nature of these constraints naturally
        // bounds the hypotenuse to the range [0,1], since it is not possible
        // to move the axes in a way such that a^2 + b^2 > 1.
        //
        // In the case of an unconstrained control, the axes move truly
        // independently and thus they can each achieve their maxima
        // simultaneously, meaning that the maximum value the distance
        // formula can produce will be based on a right triangle whose sides
        // are both 1 in length; the maximum value for this hypotenuse is
        // the square root of 2 (~1.414).
        //
        // In both cases this is an accurate representation of the magnitude
        // of the vector.  What is different is the upper bound in each case.
        if (physicalConstraints == PhysicalConstraints.CIRCULAR)
        {
            builder.setMaxMagnitude(1.0f);
        }
        else
        {
            builder.setMaxMagnitude(ROOT2);
        }
        final float desiredMagnitude = (float) Math.hypot(horizontalValue, verticalValue);
        // Protected against floating point precision loss resulting in
        // overflow beyond the boundary
        builder.setMagnitude(Math.min(desiredMagnitude, builder.getMaxMagnitude()));
        return builder.build();
    }
}