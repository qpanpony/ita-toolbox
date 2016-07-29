package org.nicegamepads;

/**
 * Exception raised when a problem is encountered with a controller.
 * 
 * @author Andrew Hayden
 */
@SuppressWarnings("serial")
public class ControllerException extends Exception
{
    /**
     * Constructs a new controller exception.
     */
    public ControllerException()
    {
        super();
    }

    /**
     * Constructs a new controller exception.
     * 
     * @param message optional message
     */
    public ControllerException(String message)
    {
        super(message);
    }

    /**
     * Constructs a new controller exception.
     * 
     * @param cause optional cause of the exception
     */
    public ControllerException(Throwable cause)
    {
        super(cause);
    }

    /**
     * Constructs a new controller exception.
     * 
     * @param message optional message
     * @param cause optional cause of the exception
     */
    public ControllerException(String message, Throwable cause)
    {
        super(message, cause);
    }
}