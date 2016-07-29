package org.nicegamepads;

import java.util.Arrays;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.CopyOnWriteArrayList;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.ScheduledFuture;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.TimeoutException;

import org.nicegamepads.configuration.ControlConfiguration;
import org.nicegamepads.configuration.ControllerConfiguration;

/**
 * Abstracts the polling of a single processor.
 * 
 * @author Andrew Hayden
 */
// FIXME: This class should not enforce itself as a singleton.
public final class ControllerPoller
{
    /**
     * The controller this poller polls.
     */
    private final NiceController controller;

    /**
     * The controller state used to store the state of the controller and
     * all of its controls.
     */
    private final ControllerState controllerState;

    /**
     * All pollers.  There is exactly one poller per controller.
     */
    private final static Map<NiceController, ControllerPoller>
        pollersByController = new HashMap<NiceController, ControllerPoller>();

    /**
     * Holds cache of granularity calculations.
     */
    private final static Map<Float, float[]> granularityBinsByGranularity =
        new ConcurrentHashMap<Float, float[]>();

    /**
     * Listeners.
     */
    private final List<ControlActivationListener> activationListeners =
        new CopyOnWriteArrayList<ControlActivationListener>();

    /**
     * Listeners.
     */
    private final List<ControlChangeListener> changeListeners =
        new CopyOnWriteArrayList<ControlChangeListener>();

    /**
     * Listeners.
     */
    private final List<ControlPollingListener> controlPollingListeners =
        new CopyOnWriteArrayList<ControlPollingListener>();

    /**
     * Listeners.
     */
    private final List<ControllerPollingListener> controllerPollingListeners =
        new CopyOnWriteArrayList<ControllerPollingListener>();

    /**
     * Used to call the {@link #poll()} method periodically.
     */
    private final PollingInvoker pollingInvoker;

    /**
     * Currently-scheduled polling task, if any.
     */
    private ScheduledFuture<?> pollingTask = null;

    /**
     * Constructs a new poller for the specified controller.
     * <p>
     * All of the controls found within the controller can be polled
     * conveniently with this object.
     * 
     * @param controller the controller to be polled
     */
    private ControllerPoller(NiceController controller) {
        this.controller = controller;
        this.controllerState = new ControllerState(controller);
        pollingInvoker = new PollingInvoker(this);
    }

    private final void init() {
        // By default, start polling 60x per second
        startPolling(1000L / 60L, TimeUnit.MILLISECONDS);
    }

    public final static ControllerPoller getInstance(NiceController controller) {
        synchronized(pollersByController) {
            ControllerPoller instance = pollersByController.get(controller);
            if (instance == null) {
                instance = new ControllerPoller(controller);
                instance.init();
                pollersByController.put(controller, instance);
            }
            return instance;
        }
    }

    /**
     * Requests that <strong>all</strong> polling cease in the near future.
     * Events that are currently enqueued are allowed to start and complete.
     */
    final static void shutdownAllPolling() {
        ControllerManager.getPollingService().shutdown();
    }

    /**
     * Requests that <strong>all</strong> polling cease as soon as possible.
     * All currently-executing events are asked to halt (via interrupt)
     * and all enqueued events are dropped on the floor.
     */
    final static void shutdownAllPollingNow() {
        ControllerManager.getPollingService().shutdownNow();
    }

    /**
     * Waits for all polling to cease.
     * 
     * @param timeout the maximum amount of time to wait for termination
     * @param unit the unit of time to wait for
     * @return <code>true</code> if all polling has ceased when this method
     * returns; otherwise, <code>false</code> if the timeout expires first
     * @throws InterruptedException if interrupted while waiting
     */
    final static boolean awaitTermination(long timeout, TimeUnit unit)
    throws InterruptedException {
        return ControllerManager.getPollingService().awaitTermination(timeout, unit);
    }

    /**
     * Retrieves the bins appropriate for the specified granularity.
     * <p>
     * If the bins haven't been cached, they are cached before being returned
     * so that later access will be fast.
     * 
     * @param granularity the granularity to use to generate the bins
     * @return an array of bins, sorted in natural order from least to
     * greatest
     */
    private final static float[] getGranularityBins(float granularity)
    {
        float[] bins = granularityBinsByGranularity.get(granularity);
        if (bins != null) {
            // Cached.  Return this immediately.
            return bins;
        }

        final List<Float> listing = new LinkedList<Float>();
        int counter = 1;
        float currentValue = 0f;
        while (currentValue > -1.0f) {
            currentValue = 0f - (((float) counter) * granularity);
            listing.add(0, currentValue);
            counter++;
        }
        listing.add(0f);
        counter = 1;
        currentValue = 0f;
        while (currentValue < 1.0f) {
            currentValue = ((float) counter) * granularity;
            listing.add(currentValue);
            counter++;
        }

        bins = new float[listing.size()];
        counter = 0;
        for (Float f : listing) {
            bins[counter++] = f;
        }

        // List complete!
        granularityBinsByGranularity.put(granularity, bins);
        return bins;
    }

    /**
     * Starts or resumes polling the controller associated with this poller.
     * <p>
     * If polling is already running, cancels the next polling interval and
     * reschedules polling at the specified interval.
     * <p>
     * In any case, polling will start after the specified interval has
     * passed.
     * 
     * @param interval the interval at which to poll
     * @param unit the time unit for the interval
     */
    private final void startPolling(final long interval, final TimeUnit unit) {
        synchronized(pollingInvoker) {
            if (pollingTask != null) {
                pollingTask.cancel(false);
            }
            pollingTask = ControllerManager.getPollingService().scheduleAtFixedRate(
                    pollingInvoker, interval, interval, unit);
        }
    }

    /**
     * Cancels any outstanding polling schedules immediately and stops all
     * future polling.  No further polling will be performed.
     * <p>
     * Note that this method may result in one last polling event executing
     * if the request to stop overlaps with such an event.  If you need
     * to guarantee that polling has terminated by the time this call
     * returns, use {@link #stopPollingAndWait(long, TimeUnit)} instead.
     */
    final void stopPolling() {
        synchronized(pollingInvoker) {
            if (pollingTask != null) {
                pollingTask.cancel(false);
            }
            pollingTask = null;
        }
    }

    /**
     * Cancels any outstanding polling schedules immediately waits until
     * the currently-executing polling process, if any, has completed.
     * After this method has returned, it is guaranteed that no further
     * polling events will be enqueued for dispatch (any unprocessed
     * events will still be fired).
     */
    final void stopPollingAndWait(final long interval, final TimeUnit unit)
    throws InterruptedException, ExecutionException, TimeoutException {
        synchronized(pollingInvoker) {
            try {
                if (pollingTask != null) {
                    pollingTask.cancel(false);
                    pollingTask.get(interval, unit);
                }
            } finally {
                pollingTask = null;
            }
        }
    }

    /**
     * Forces this controller to poll all of its controls immediately.
     * <p>
     * Polling will dispatch events for the controls as necessary.
     * 
     * @throws IllegalStateException if no configuration has been set for
     * this poller
     */
    private final void poll() {
        // Start by obtaining a copy of the current configuration.  We will
        // use only this copy for our entire method lifetime.
        // Since the source is volatile we are guaranteed that we are getting
        // the latest copy here.
        final ControllerConfiguration config = controller.getConfiguration();
        if (config == null) {
            throw new IllegalStateException("Null configuration.");
        }

        ControlConfiguration controlConfig = null;
        final long now = System.currentTimeMillis();
        controllerState.timestamp = now;

        // Poll the controller
        try {
            config.getController().pollAllControls(controllerState);
        } catch(ControllerException e) {
            // FIXME: raise event!
            e.printStackTrace();
            stopPolling();
        }

        // Process each control.
        for (ControlState state : controllerState.controlStates) {
            // Look up configuration for this control
            controlConfig = config.getConfiguration(state.control);
            // Poll the value
            float polledValue = state.rawCurrentValue;
            // Transform according to configuration rules
            polledValue = transform(polledValue, controlConfig, state.control.getControlType());
            // Get any user ID bound to this value
            boolean forceFireTurboEvent = false;

            switch (state.control.getControlType()) {
                case DISCRETE_INPUT:
                    state.newValue(polledValue, now, polledValue == 1f);
                    // Check for turbo stuff
                    if (controlConfig.isTurboEnabled() && polledValue == 1f) {
                        if (controlConfig.getTurboDelayMillis() == 0) {
                            // If button is pressed, force an event.
                            forceFireTurboEvent = true;
                        } else if (state.lastTurboTimerStart > 0) {
                            // There is a specific delay for turbo and the
                            // timer is running.  Has enough time gone by?
                            if (now - state.lastTurboTimerStart >= controlConfig.getTurboDelayMillis()) {
                                // Yes.
                                forceFireTurboEvent = true;
                            }
                        }
                    }
                    break;
                case CONTINUOUS_INPUT:
                    state.newValue(polledValue, now, false);
                    break;
                default:
                    throw new RuntimeException("Unsupported control type: "
                            + state.control.getControlType());
            }

            ControlEvent event = makeEvent(state, controlConfig);
            // Figure out which events need to be fired.

            // Start with activation/deactivation events:
            if (event.previousValueId != Integer.MIN_VALUE && event.currentValueId != Integer.MIN_VALUE) {
                // Both values are bound.
                if (event.previousValueId != event.currentValueId) {
                    // Previous id deactivated.
                    dispatchControlDeactivated(event);
                    // Current id activated
                    dispatchControlActivated(event);
                } else {
                    // Previous id is still active.
                    if (forceFireTurboEvent) {
                        // Turbo mode engaged.  Force an event to fire even
                        // though nothing has really changed.
                        dispatchControlActivated(event);
                    }
                }
            } else if (event.previousValueId != Integer.MIN_VALUE) {
                // Previous value is bound but current value isn't.
                dispatchControlDeactivated(event);
            } else if (event.currentValueId != Integer.MIN_VALUE) {
                // Current value is bound but previous value isn't.
                dispatchControlActivated(event);
            } else {
                // Neither the current nor the previous value is bound
                // No-op (only thing that can happen is a change event,
                // which we don't test by ID since IDs aren't guaranteed
                // to be unique).
            }

            // Check for a value change and fire event if the value has changed
            if (event.previousValue != event.currentValue) {
                dispatchValueChanged(event);
            }

            // Fire generic polling event
            dispatchControlPolled(event);
        }

        // Dispatch controller-polled event.
        // We check to see if there are any listeners or not as cloning the
        // controller state can be a relatively expensive operation.  If
        // nobody is listening, it will be slightly less resource-intensive
        // to simply skip cloning the state.
        if (controllerPollingListeners.size() > 0) {
            ControllerState stateCopy = new ControllerState(controllerState);
            dispatchControllerPolled(stateCopy);
        }
    }

    /**
     * Applies any and all transforms to the polled value, as defined by
     * the configuration, and returns the result.
     * 
     * @param polledValue the value that was polled from the control
     * @param controlConfig the control configuration to consult
     * @param the type of control
     * @return the post-transform result for the value
     */
    private final float transform(float polledValue, final ControlConfiguration controlConfig, final NiceControlType controlType) {
        // STEP 1: Granularity
        // Get granularity bins and collapse.
        if (!Float.isNaN(controlConfig.getGranularity())) {
            final float[] bins = getGranularityBins(controlConfig.getGranularity());
            int index = Arrays.binarySearch(bins, polledValue);
            if (index < 0) {
                // Value isn't an exact match to any bin, so we must clamp
                // it to the bin boundary nearest to zero
                // Index returned by binary search is
                // (-1 * insertionPoint) - 1, such that an insertion point
                // of zero maps to -1, one maps to -2, and so on.
                // Start by getting 
                index = (index + 1) * -1;
                // Now we have zero mapping to 0, one to 1, two to 2...
                // If the value is less than zero, it has to move in a positive
                // direction, and therefore it must have 1 added to its index
                if (polledValue < 0)
                {
                    index++;
                }

                // Now we have the right bin for the value.
                polledValue = bins[index];
            }
        }

        // STEP 2: Dead zone
        if (!Float.isNaN(controlConfig.getDeadZoneLowerBound())) {
            // We have a dead zone to consider.
            if (controlConfig.getDeadZoneLowerBound() <= polledValue && polledValue <= controlConfig.getDeadZoneUpperBound()) {
                // Value is in the dead zone.  Set to zero.
                polledValue = 0f;
            }
        }

        // STEP 3: Inversion
        if (controlConfig.isInverted()) {
            if (controlType == NiceControlType.DISCRETE_INPUT) {
                // FIXME: need to correct this behavior.
                // Buttons should be treated specially... this was originally
                // for buttons when buttons existed as a type

                // Reflect around 0.5f
                polledValue = 1f - polledValue;
            } else {
                // Reflect around 0f
                polledValue *= -1f;
            }
        }

        // STEP 4: Recentering
        if (!Float.isNaN(controlConfig.getCenterValueOverride()) && controlConfig.getCenterValueOverride() != 0f) {
            float positiveExpansion;
            float negativeExpansion;
            if (controlConfig.getCenterValueOverride() > 0f) {
                positiveExpansion = 1f - controlConfig.getCenterValueOverride();
                negativeExpansion = 1f + controlConfig.getCenterValueOverride();
            } else {
                negativeExpansion = 1f - Math.abs(controlConfig.getCenterValueOverride());
                positiveExpansion = 1f - controlConfig.getCenterValueOverride();
            }

            if (polledValue > 0) {
                polledValue *= positiveExpansion;
            } else if (polledValue < 0) {
                polledValue *= negativeExpansion;
            } else {
                polledValue = controlConfig.getCenterValueOverride();
            }
        }

        // STEP 5: Clamp to sane range
        // We don't expect to get out of this range because of any errors
        // in the code, but rather it is possible because of floating point
        // precision loss.
        if (polledValue < -1.0f) {
            polledValue = -1.0f;
        } else if (polledValue > 1.0f) {
            polledValue = 1.0f;
        }

        // All done!
        return polledValue;
    }

    /**
     * Adds a listener to this poller to be notified whenever
     * a control is activated or deactivated.
     * <p>
     * It is guaranteed that all control-related events will be
     * dispatched before any {@link ControllerPollingListener} events.
     * Thus the caller may safely rely on the {@link ControllerPollingListener}
     * events as a notification mechanism that all values seen in the
     * control-related events since the previous controller-polled event
     * were obtained from one controller polling session.
     * <p>
     * Additionally, it is guaranteed that the timestamp on the
     * {@link ControllerState} object passed to the listener will match
     * the timestamps on any and all {@link ControlEvent}s that were
     * dispatched as part of that same same polling operation.
     * 
     * @param listener the listener to add.
     */
    public final void addControlActivationListener(final ControlActivationListener listener) {
        activationListeners.add(listener);
    }

    /**
     * Removes the specified listener.
     * 
     * @param listener the listener to be removed
     */
    public final void removeControlActivationListener(final ControlActivationListener listener) {
        activationListeners.remove(listener);
    }

    /**
     * Adds a listener to this poller to be notified whenever
     * a control's value changes.
     * <p>
     * It is guaranteed that all control-related events will be
     * dispatched before any {@link ControllerPollingListener} events.
     * Thus the caller may safely rely on the {@link ControllerPollingListener}
     * events as a notification mechanism that all values seen in the
     * control-related events since the previous controller-polled event
     * were obtained from one controller polling session.
     * <p>
     * Additionally, it is guaranteed that the timestamp on the
     * {@link ControllerState} object passed to the listener will match
     * the timestamps on any and all {@link ControlEvent}s that were
     * dispatched as part of that same same polling operation.
     * 
     * @param listener the listener to add.
     */
    public final void addControlChangeListener(ControlChangeListener listener) {
        changeListeners.add(listener);
    }

    /**
     * Removes the specified listener.
     * 
     * @param listener the listener to be removed
     */
    public final void removeControlChangeListener(final ControlChangeListener listener) {
        changeListeners.remove(listener);
    }

    /**
     * Adds a listener to this poller to be notified whenever
     * a control is polled.
     * <p>
     * It is guaranteed that all control-related events will be
     * dispatched before any {@link ControllerPollingListener} events.
     * Thus the caller may safely rely on the {@link ControllerPollingListener}
     * events as a notification mechanism that all values seen in the
     * control-related events since the previous controller-polled event
     * were obtained from one controller polling session.
     * <p>
     * Additionally, it is guaranteed that the timestamp on the
     * {@link ControllerState} object passed to the listener will match
     * the timestamps on any and all {@link ControlEvent}s that were
     * dispatched as part of that same same polling operation.
     * 
     * @param listener the listener to add.
     */
    public final void addControlPollingListener(final ControlPollingListener listener) {
        controlPollingListeners.add(listener);
    }

    /**
     * Removes the specified listener.
     * 
     * @param listener the listener to be removed
     */
    public final void removeControlPollingListener(final ControlPollingListener listener) {
        controlPollingListeners.remove(listener);
    }

    /**
     * Adds a listener to this poller to be notified whenever
     * the controller completes polling.
     * <p>
     * It is guaranteed that all control-related events will be
     * dispatched before any {@link ControllerPollingListener} events.
     * Thus the caller may safely rely on the {@link ControllerPollingListener}
     * events as a notification mechanism that all values seen in the
     * control-related events since the previous controller-polled event
     * were obtained from one controller polling session.
     * <p>
     * Additionally, it is guaranteed that the timestamp on the
     * {@link ControllerState} object passed to the listener will match
     * the timestamps on any and all {@link ControlEvent}s that were
     * dispatched as part of that same same polling operation.
     * 
     * @param listener the listener to add.
     */
    public final void addControllerPollingListener(final ControllerPollingListener listener) {
        controllerPollingListeners.add(listener);
    }

    /**
     * Removes the specified listener.
     * 
     * @param listener the listener to be removed
     */
    public final void removeControllerPollingListener(final ControllerPollingListener listener) {
        controllerPollingListeners.remove(listener);
    }

    /**
     * Makes an event from the specified state and configuration.
     * 
     * @param state the state to base the event on
     * @param config the config associated with the control
     * @return the event
     */
    private final static ControlEvent makeEvent(final ControlState state, final ControlConfiguration config) {
        return new ControlEvent(
                state.control.getController(),
                state.control, config.getUserDefinedId(),
                state.currentValue, config.getValueId(state.currentValue),
                state.lastValue, config.getValueId(state.lastValue));
    }

    /**
     * Dispatches a new "control activated" event to all registered
     * listeners.
     * 
     * @param event the event to be dispatched
     */
    private final void dispatchControlActivated(final ControlEvent event) {
        ControllerManager.getEventDispatcher().submit(new LoggingRunnable(){
            @Override
            protected void runInternal() {
                for (ControlActivationListener listener : activationListeners) {
                    listener.controlActivated(event);
                }
            }
        });
    }

    /**
     * Dispatches a new "control deactivated" event to all registered
     * listeners.
     * 
     * @param event the event to be dispatched
     */
    private final void dispatchControlDeactivated(final ControlEvent event) {
        ControllerManager.getEventDispatcher().submit(new LoggingRunnable(){
            @Override
            protected void runInternal() {
                for (ControlActivationListener listener : activationListeners) {
                    listener.controlDeactivated(event);
                }
            }
        });
    }

    /**
     * Dispatches a new "value changed" event to all registered
     * listeners.
     * 
     * @param event the event to be dispatched
     */
    private final void dispatchValueChanged(final ControlEvent event) {
        ControllerManager.getEventDispatcher().submit(new LoggingRunnable(){
            @Override
            protected void runInternal() {
                for (ControlChangeListener listener : changeListeners) {
                    listener.valueChanged(event);
                }
            }
        });
    }

    /**
     * Dispatches a new "control polled" event to all registered
     * listeners.
     * 
     * @param event the event to be dispatched
     */
    private final void dispatchControlPolled(final ControlEvent event) {
        ControllerManager.getEventDispatcher().submit(new LoggingRunnable(){
            @Override
            protected void runInternal() {
                for (ControlPollingListener listener : controlPollingListeners) {
                    listener.controlPolled(event);
                }
            }
        });
    }

    /**
     * Dispatches a new "controller polled" event to all registered
     * listeners.
     * 
     * @param state the state to be dispatched
     */
    private final void dispatchControllerPolled(final ControllerState state) {
        ControllerManager.getEventDispatcher().submit(new LoggingRunnable(){
            @Override
            protected void runInternal() {
                for (ControllerPollingListener listener : controllerPollingListeners) {
                    listener.controllerPolled(state);
                }
            }
        });
    }

    /**
     * Utility class to invoke polling on a controller poller.
     * 
     * @author Andrew Hayden
     */
    private final static class PollingInvoker extends LoggingRunnable {
        /**
         * The poller to invoke polling on.
         */
        private final ControllerPoller poller;

        /**
         * Constructs a new invoker that will invoke polling on the specified
         * controller poller.
         * 
         * @param poller the poller to invoke polling on
         */
        PollingInvoker (final ControllerPoller poller) {
            this.poller = poller;
        }

        @Override
        protected final void runInternal() {
            poller.poll();
        }
    }
}