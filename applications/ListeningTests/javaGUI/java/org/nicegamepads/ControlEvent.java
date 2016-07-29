package org.nicegamepads;

/**
 * Encapsulates information about an event from a control.
 * 
 * @author Andrew Hayden
 */
public class ControlEvent
{
    /**
     * The parent controller in which the source control resides, if
     * known; otherwise, <code>null</code>.
     * <p>
     * If set, this is always the immediate parent controller of the
     * control.
     */
    public final NiceController sourceController;

    /**
     * The control that generated the event.
     */
    public final NiceControl sourceControl;

    /**
     * The user-defined ID for the source control, if any; otherwise,
     * {@link Integer#MIN_VALUE}.
     */
    public final int userDefinedControlId;

    /**
     * The current value of the control at the time this event was fired,
     * or {@link Float#NaN} if there is no applicable value.
     */
    public final float currentValue;

    /**
     * The current user-defined value ID bound to the current value, if any;
     * otherwise, {@link Integer#MIN_VALUE}.
     */
    public final int currentValueId;

    /**
     * The value of the control at the previous time the source control,
     * was polled, or {@link Float#NaN} if there is no applicable value.
     */
    public final float previousValue;

    /**
     * The current user-defined value ID bound to the previous value, if any;
     * otherwise, {@link Integer#MIN_VALUE}.
     */
    public final int previousValueId;

    /**
     * Constructs a new control event.
     * 
     * @param topLevelSourceController
     * @param sourceControl
     * @param userDefinedControlId
     * @param currentValue
     * @param currentValueId
     * @param previousValue
     * @param previousValueId
     */
    public ControlEvent(NiceController topLevelSourceController,
            NiceControl sourceControl, int userDefinedNiceControlId,
            float currentValue, int currentValueId, float previousValue,
            int previousValueId)
    {
        super();
        this.sourceController = topLevelSourceController;
        this.sourceControl = sourceControl;
        this.userDefinedControlId = userDefinedNiceControlId;
        this.currentValue = currentValue;
        this.currentValueId = currentValueId;
        this.previousValue = previousValue;
        this.previousValueId = previousValueId;
    }

    @Override
    public String toString()
    {
        StringBuilder buffer = new StringBuilder();
        buffer.append(ControlEvent.class.getName());
        buffer.append(": [");
        buffer.append("sourceController=");
        buffer.append(sourceController);
        buffer.append(", sourceNiceControl=");
        buffer.append(sourceControl);
        buffer.append(", userDefinedControlId=");
        buffer.append(userDefinedControlId);
        buffer.append(", previousValue=");
        buffer.append(previousValue);
        buffer.append(", previousValueId=");
        buffer.append(previousValueId);
        buffer.append(", currentValue=");
        buffer.append(currentValue);
        buffer.append(", currentValueId=");
        buffer.append(currentValueId);
        buffer.append("]");
        return buffer.toString();
    }
}