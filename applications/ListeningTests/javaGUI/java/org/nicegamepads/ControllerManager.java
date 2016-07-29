package org.nicegamepads;

import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;


/**
 * Main entry point into NiceGamepads.
 * <p>
 * This class is threadsafe.
 * 
 * @author Andrew Hayden
 */
public final class ControllerManager
{
    /**
     * The one and only event dispatcher for controller polling.
     */
    private static volatile ExecutorService eventDispatcher = null;

    /**
     * Polling service that handles polling of the controller.
     */
    private static volatile ScheduledExecutorService pollingService = null;

    /**
     * Main lock.
     */
    private final static Object staticLock = new Object();

    /**
     * State of the framework.
     */
    private static volatile FrameworkState state =
        FrameworkState.UNINITIALIZED;

    /**
     * Private constructor discourages unwanted instantiation.
     */
    private ControllerManager()
    {
        // Private constructor discourages unwanted instantiation.
    }

    /**
     * Shuts down the framework gracefully in the near future.
     * <p>
     * This method terminates all polling and event dispatching, allowing
     * any currently-executing and already-enqueued tasks to complete
     * normally and then gracefully exiting.  The method returns immediately
     * in all cases, and may be called multiple times safely (calls after
     * the first do nothing).
     * <p>
     * If the framework has not yet been initialized, this method throws an
     * {@link IllegalStateException}.
     * 
     * @see ExecutorService#shutdown()
     * @throws IllegalStateException if the framework has not yet been
     * initialized
     */
    public final static void shutdown()
    {
        synchronized(staticLock)
        {
            if (state == FrameworkState.UNINITIALIZED)
            {
                throw new IllegalStateException(
                        "Framework has not been initialized.");
            }

            getPollingService().shutdown();
            getEventDispatcher().shutdown();
            state = FrameworkState.SHUTDOWN; 
        }
    }

    /**
     * Shuts down the framework immediately.
     * <p>
     * This method immediately terminates all polling and event dispatching,
     * attempting to interrupt any currently-executing and cancellent all
     * enqueued tasks that haven't started execution.
     * <p>
     * The method returns immediately in all cases, but there is no guarantee
     * that all threads will exit in any given time frame.
     * <p>
     * This method may be called multiple times safely (calls after
     * the first do nothing).
     * <p>
     * If the framework has not yet been initialized, this method throws an
     * {@link IllegalStateException}.
     * 
     * @see ExecutorService#shutdownNow()
     * @throws IllegalStateException if the framework has not yet been
     * initialized
     */
    public final static void shutdownNow()
    {
        synchronized(staticLock)
        {
            if (state == FrameworkState.UNINITIALIZED)
            {
                throw new IllegalStateException(
                        "Framework has not been initialized.");
            }
    
            getPollingService().shutdownNow();
            getEventDispatcher().shutdownNow();
            state = FrameworkState.SHUTDOWN; 
        }
    }

    /**
     * Returns whether or not the framework has shutdown.
     * 
     * @return <code>true</code> if all framework services have halted.  There
     * may still be outstanding or currently-running tasks remaining.
     * 
     * @see ExecutorService#isShutdown()
     */
    public final static boolean isShutdown()
    {
        synchronized(staticLock)
        {
            if (state == FrameworkState.UNINITIALIZED)
            {
                return false;
            }
            return getPollingService().isShutdown()
                && getEventDispatcher().isShutdown();
        }
    }

    /**
     * Returns whether or not the framework has terminated.
     * 
     * @return <code>true</code> if all framework services have halted and
     * there are no outstanding or currently-running tasks remaining.
     * 
     * @see ExecutorService#isTerminated()
     */
    public final static boolean isTerminated()
    {
        synchronized(staticLock)
        {
            if (state == FrameworkState.UNINITIALIZED)
            {
                return false;
            }
            return getPollingService().isTerminated()
                && getEventDispatcher().isTerminated();
        }
    }

    /**
     * Waits up to the specified amount of time for all framework services
     * to terminate.
     * <p>
     * This method does not initiate a shutdown.  Rather, it waits until
     * all services have shutdown and all tasks have terminated.  Once both
     * conditions are true, or the specified timeout expires, this method
     * returns.
     * 
     * @param timeout the maximum amount of time to wait for termination
     * @param unit the unit of time to wait for
     * @return <code>true</code> if all services have shutdown and all
     * tasks have terminated before the specified timeout elapsed;
     * otherwise, <code>false</code>
     * @throws InterruptedException if interrupted while waiting
     * @throws IllegalStateException if the framework has not yet been
     * initialized
     * @see ExecutorService#awaitTermination(long, TimeUnit)
     */
    public final static boolean awaitTermination(long timeout, TimeUnit unit)
    throws InterruptedException
    {
        synchronized(staticLock)
        {
            if (state == FrameworkState.UNINITIALIZED)
            {
                throw new IllegalStateException(
                        "Framework has not been initialized.");
            }

            long startTime = System.currentTimeMillis();
            if (timeout <= 0)
            {
                throw new IllegalArgumentException(
                        "Timeout must be greater than 0: " + timeout);
            }
    
            long timeLeft = unit.toMillis(timeout);
            long endTime = startTime + timeLeft;
    
            boolean success = getPollingService().awaitTermination(
                    timeLeft, TimeUnit.MILLISECONDS);
            if (success)
            {
                // Try to terminate other services
                timeLeft = endTime - System.currentTimeMillis();
                if (timeLeft > 0)
                {
                    return getEventDispatcher().awaitTermination(
                            timeLeft, TimeUnit.MILLISECONDS);
                }
                else
                {
                    return false;
                }
            }
            else
            {
                return false;
            }
        }
    }

    /**
     * Initializes the framework, starting all services and preparing the
     * system for general usage.
     * <p>
     * This method must be called before attempting to access any of the
     * services in the framework.  Failure to do so will result, in most cases,
     * in an {@link IllegalStateException} being thrown.  This method may
     * be called more than once; additional calls have no effect.
     * <p>
     * Once the framework has been shut down via
     * {@link #shutdown()} or {@link #shutdownNow()}, it is no longer
     * permissible to call this method.  Doing so will result in an
     * {@link IllegalStateException}.
     * 
     * @return <code>true</code> if this call caused the framework to startup;
     * otherwise, <code>false</code> (i.e., method has already been called)
     */
    public final static boolean initialize()
    {
        synchronized(staticLock)
        {
            if (state == FrameworkState.SHUTDOWN)
            {
                throw new IllegalStateException(
                        "Framework is in shutdown state.");
            }

            if (state == FrameworkState.UNINITIALIZED)
            {
                eventDispatcher = Executors.newSingleThreadExecutor();
                pollingService = Executors.newSingleThreadScheduledExecutor();
                state = FrameworkState.INITIALIZED;
                return true;
            }
            return false;
        }
    }

    /**
     * Returns the polling service for the framework.
     * 
     * @return the polling service
     * @throws IllegalStateException if the framework has not yet been
     * initialized via {@link #initialize()}
     */
    public final static ScheduledExecutorService getPollingService()
    {
        synchronized(staticLock)
        {
            if (state == FrameworkState.UNINITIALIZED)
            {
                throw new IllegalStateException(
                        "Framework has not been initialized.");
            }
            return pollingService;
        }
    }

    /**
     * Returns the event dispatcher service for the framework.
     * 
     * @return the event dispatcher service
     * @throws IllegalStateException if the framework has not yet been
     * initialized via {@link #initialize()}
     */
    public final static ExecutorService getEventDispatcher()
    {
        synchronized(staticLock)
        {
            if (state == FrameworkState.UNINITIALIZED)
            {
                throw new IllegalStateException(
                        "Framework has not been initialized.");
            }
            return eventDispatcher;
        }
    }

    /**
     * Possible states of the framework.
     * 
     * @author Andrew Hayden
     */
    private static enum FrameworkState
    {
        UNINITIALIZED, INITIALIZED, SHUTDOWN;
    }
}