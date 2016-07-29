package org.nicegamepads;

public enum NiceControlType
{
    /**
     * Represents an input control whose values vary within the continuous
     * range of [-1, 1].  Any value in the range could potentially be read.
     * This is typically used for so-called "analog" controls (which may or
     * may not actually <em>be</em> analog), such as sticks and rudders and
     * pressure-sensitive buttons.
     */
    CONTINUOUS_INPUT,

    /**
     * Represents an input control whose values are confined to a specific
     * set of discrete values in the range [-1, 1].  Only certain values in
     * the range can ever be read.  This is typically used for "digital"
     * controls such as directional pads and simple on-or-off buttons.
     */
    DISCRETE_INPUT,

    /**
     * Represents a type of control that provides feedback to the user,
     * often in the form of a "rumbler" or an LED.
     */
    FEEDBACK;
}
