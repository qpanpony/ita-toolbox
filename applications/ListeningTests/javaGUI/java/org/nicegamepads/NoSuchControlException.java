package org.nicegamepads;

/**
 * Represents an error condition where there is an attempt to access a
 * control that does not exist.
 * 
 * @author Andrew Hayden
 */
@SuppressWarnings("serial")
public class NoSuchControlException extends RuntimeException
{
    /**
     * Constructs a new exception.
     */
    public NoSuchControlException()
    {
        super();
    }

    /**
     * @param message
     * @param cause
     */
    public NoSuchControlException(String message, Throwable cause)
    {
        super(message, cause);
    }

    /**
     * @param message
     */
    public NoSuchControlException(String message)
    {
        super(message);
    }

    /**
     * @param cause
     */
    public NoSuchControlException(Throwable cause)
    {
        super(cause);
    }
}