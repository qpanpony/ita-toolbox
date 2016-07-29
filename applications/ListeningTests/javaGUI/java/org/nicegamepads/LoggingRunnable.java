package org.nicegamepads;

/**
 * Utility class that logs errors to stderr.
 * <p>
 * This is useful with executors or any other entities that utterly suppress
 * and swallow errors, making things difficult to debug.
 * 
 * @author Andrew Hayden
 */
public abstract class LoggingRunnable implements Runnable
{

    @Override
    public final void run()
    {
        try
        {
            runInternal();
        }
        catch(Throwable t)
        {
            t.printStackTrace();
            throw new RuntimeException(t);
        }
    }

    /**
     * Performs the work for this task.  Any uncaught exception is logged.
     * This does not mean you should not catch exceptions properly - it
     * merely means that any exceptions that do slip through will become
     * very visible.
     */
    protected abstract void runInternal();
}
