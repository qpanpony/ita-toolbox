package org.nicegamepads;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import net.java.games.input.Component;
import net.java.games.input.Controller;
import net.java.games.input.Controller.Type;
import net.java.games.input.ControllerEnvironment;
import net.java.games.input.Rumbler;

import org.nicegamepads.configuration.ControllerConfiguration;
import org.nicegamepads.configuration.ControllerConfigurationBuilder;

public final class NiceController
{
    /**
     * If a QWERTY keyboard is hanging around it probably has a "control" for
     * each letter, since there are 26 of them it would be extremely weird for
     * it to be any other way (possibly with the exception of a digital
     * control with many distinct values).
     */
    private final static Set<String> PROBABLE_ENGLISH_KEYBOARD_COMPONENT_NAMES =
        Collections.unmodifiableSet(
                new HashSet<String>(Arrays.asList(new String[] {
                    "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K",
                    "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V",
                    "W", "X", "Y", "Z"
        })));

    /**
     * Even most non-US keyboards have function keys.  In a brief survey of
     * about 20 keyboards online, all had "F1", "F2", "F3" (etc) regardless
     * of the language or usual OS platform (e.g., Macintosh-branded x86 versus
     * generic x86 hardware).  Furthermore in every case I have seen, the
     * function keys are actually labeled with a Latin-style letter "F".
     * <p>
     * The strings are declared here so they will be in Java's internal
     * modified-UTF-16 representation at runtime.
     */
    private final static Set<String> PROBABLE_ANY_KEYBOARD_COMPONENT_NAMES =
        Collections.unmodifiableSet(
                new HashSet<String>(Arrays.asList(new String[] {
                    "F1", "F2", "F3", "F4", "F5", "F6", "F7", "F8"
        })));

    /**
     * Map of all NiceController objects by Controller instance.
     */
    private final static Map<Controller, NiceController>
        wrappersByJinputController = new HashMap<Controller, NiceController>();

    /**
     * Cache of subcontrols by controller (non-recursive).
     */
    private final static Map<NiceController, List<NiceControl>>
        cachedControlsByController = Collections.synchronizedMap(
                new HashMap<NiceController, List<NiceControl>>());

    /**
     * The controller being wrapped.
     */
    private final Controller jinputController;

    /**
     * Fingerprint for this kind of controller.
     */
    private volatile int fingerprint = 0;

    /**
     * Whether or not this is a gamepad-like controller.
     */
    private volatile boolean gamepadLike = false;

    /**
     * The configuration for this controller.
     */
    // TODO: Make NiceController immutable and use the builder pattern?
    private volatile ControllerConfiguration config = null;

    /**
     * Mutex for polling.
     */
    private final Object pollingLock = new Object();

    /**
     * Returns the wrapper for the specified controller; there is exactly
     * one wrapper per physical device, and no more.
     * 
     * @param controller the device to be wrapped
     * @return the singleton wrapper for the physical device
     */
    final static NiceController getInstance(Controller controller)
    {
        synchronized(wrappersByJinputController)
        {
            NiceController instance = wrappersByJinputController.get(controller);
            if (instance == null) {
                instance = new NiceController(controller);
                instance.init();
                wrappersByJinputController.put(controller, instance);
            }
            return instance;
        }
    }

    /**
     * Constructs a new wrapper for the specific controller.
     * <p>
     * All NiceController instances share a static cache of objects that is
     * used to provide and enforce consistently safe access to the underyling
     * physical device.
     * 
     * @param jinputController the controller to wrap
     */
    private NiceController(final Controller jinputController)
    {
        this.jinputController = jinputController;
    }

    /**
     * Must be called after the constructor in order to properly configure
     * the controller with configuration information and caching of controls.
     */
    private final void init()
    {
        List<NiceControl> discoveredControls = new ArrayList<NiceControl>();
        getControlsHelper(this.jinputController, discoveredControls);
        cachedControlsByController.put(this, Collections.unmodifiableList(discoveredControls));
        fingerprint = generateFingerprint();
        gamepadLike = isGamepadLikeInternal();
        config = new ControllerConfigurationBuilder(this).build();
    }

    public final int getFingerprint()
    {
        return fingerprint;
    }

    public final String getDeclaredName()
    {
        return jinputController.getName();
    }

    /**
     * Recursively retrieves all controls for the specified controller,
     * in a breadth-first search of the controller space.
     * 
     * @param jinputController the controller to read from
     * @param results running list of all controls found so far
     */
    private final void getControlsHelper(
            Controller jinputController,
            List<NiceControl> results)
    {
        for (Component jinputComponent : jinputController.getComponents())
        {
            results.add(NiceControl.getInstance(jinputComponent, this));
        }
        for (Controller subController : jinputController.getControllers())
        {
            getControlsHelper(subController, results);
        }
    }

    /**
     * Returns an unmodifiable listing of all of the controls of the
     * specified controller and any subcontrollers contained therein.
     * <p>
     * It is usually unimportant under which subcontroller a control resides,
     * so long as the control can be found and configured.  To that end,
     * this method "flattens" the controller space and simply
     * returns a list of every control in the entire controller, regardless of
     * any nested subcontrollers that may be present in the device
     * (for example, an integrated mouse in a keyboard).
     * <p>
     * Since controllers cannot gain or lose controls at runtime, this method
     * caches results.  Subsequent calls will generally be much faster.
     * 
     * @param controller the controller to find the controls of
     * @return an unmodifiable list of all the controls in the controller
     */
    public final List<NiceControl> getControls()
    {
        return cachedControlsByController.get(this);
    }

    /**
     * Returns a new, independent list of all of the controls in this
     * controller that are of the specified type.
     * 
     * @param controller the controller to search
     * @param type the type of control to find
     * @return a new list containing all of the controls of the specified type
     */
    public final List<NiceControl> getControlsByType(NiceControlType type)
    {
        List<NiceControl> allControls = getControls();
        List<NiceControl> matchingControls = new ArrayList<NiceControl>();
        for (NiceControl control : allControls)
        {
            if (control.getControlType() == type)
            {
                matchingControls.add(control);
            }
        }
        return matchingControls;
    }

    /**
     * Calculated whether or not the controller is gamepad-like.
     * 
     * @param controller the controller to test
     * @return <code>true</code> if the controller is gamepad-like;
     * otherwise, <code>false</code>
     * @see #isGamepadLike(Controller)
     */
    private final boolean isGamepadLikeInternal()
    {
        // First we'll check some common types.  These can lie, though,
        // depending on the manufacturer, so we're only going to give them
        // a brief look.
        Type controllerType = jinputController.getType();
        if (controllerType == Type.GAMEPAD)
        {
            // Claims to be a gamepad.  This seems good enough to me.
            return true;
        }

        // Not a gamepad by declaration.  Is it declared as a keyboard or
        // mouse?
        if (controllerType == Type.KEYBOARD
                || controllerType == Type.MOUSE)
        {
            // Definitely reporting itself as a keyboard or a mouse.
            // No arguments here!
            return false;
        }

        // OK, so it doesn't have a type we can filter.  What about its name?
        // Let's convert it to uppercase in the host's locale and see if
        // it contains "KEYBOARD" or "MOUSE"... a non-English device might
        // contain a different word, but we can't have a dictionary of
        // every language's definition for "keyboard" or "mouse" here.
        // We'll try to catch those later on with heuristics.
        String controllerName = getDeclaredName();
        if (controllerName != null)
        {
            String uppercase = controllerName.toUpperCase();
            if (uppercase.contains("KEYBOARD")
                    || uppercase.contains("MOUSE"))
            {
                // The device name says that it is a mouse or a keyboard.
                // This seems to indicate that it isn't a gamepad.
                return false;
            }

            if (uppercase.contains("RECEIVER"))
            {
                // Probably just an intermediary component, ignore
                return false;
            }
        }

        // ====================================================================
        // NON-DETERMINISTIC SECTION FOLLOWS
        // ====================================================================
        // In my experience, anything that is not a keyboard or a mouse
        // is potentially a game controller.  This could be because the
        // manufacturer got lazy or because the controller contains many
        // types of controls - such as a rudder or wheel - and they had to
        // pick some vague category that didn't really apply.
        // Here we will try some reasonable heuristics to filter out
        // badly-behaving or poorly-named keyboard/mouse devices.

        // First, check for rumblers.  It is extremely unlikely that any
        // keyboard or mouse will have a rumbler.
        Rumbler[] rumblers = jinputController.getRumblers();
        if (rumblers != null && rumblers.length > 0)
        {
            // If it has a rumbler let's just assume it is indeed a gamepad.
            return true;
        }

        // We'll have to do some more work now to separate the controllers
        // from the poorly-reporting hardware in the universe, as well as
        // keyboards and/or mice whose names are reported in non-English
        // form, e.g. "clavier" (keyboard in French) or "souris" (mouse in
        // French).
        List<NiceControl> controls = getControls();

        // Next up, do a brute force search on the named controls to see if
        // they look like those on a keyboard... let's start by getting a
        // list of all the names of the various controls and converting
        // them to uppercase in the host's locale.
        Set<String> controlNames = new HashSet<String>();
        for (NiceControl control : controls)
        {
            String controlName = control.getDeclaredName();
            if (controlName != null
                    && control.getControlType() != NiceControlType.FEEDBACK)
            {
                // Convert 
                controlNames.add(controlName.toUpperCase());
            }
        }

        // Now check if those control names are a superset of the
        // 26 Latin characters in the English alphabet / English keyboard.
        Set<String> temp = new HashSet<String>(controlNames);
        temp.retainAll(PROBABLE_ENGLISH_KEYBOARD_COMPONENT_NAMES);
        if (temp.equals(PROBABLE_ENGLISH_KEYBOARD_COMPONENT_NAMES))
        {
            // Contains all 26 letters of the english alphabet.  Almost
            // certainly a QWERTY US keyboard.
            return false;
        }

        // Failing this, weed out any non-US keyboards.  Most have function
        // keys F1-F8 at least, even if they name their other keys in
        // the default locale encoding (I suspect).  We will search on those.
        temp = new HashSet<String>(controlNames);
        temp.retainAll(PROBABLE_ANY_KEYBOARD_COMPONENT_NAMES);
        if (temp.equals(PROBABLE_ANY_KEYBOARD_COMPONENT_NAMES)
                && controlNames.size() > 50)
        {
            // Contains 8 'F' keys and at least 50 total controls (an
            // arbitrary but reasonable amount); Almost certainly a
            // keyboard of some type.
            return false;
        }

        // If we make it this far we've got something that doesn't claim
        // to be a keyboard or a mouse, doesn't have the 26 English letters
        // as control names, and doesn't have at least 50 controls total
        // with 8 of them being function keys.
        // This seems a reasonable place to draw the line.
        // What could conceivably get through here would be non-English-named
        // mice that also fail to report themselves as mice.  This should be
        // (extremely) rare.
        return true;
    }

    /**
     * Returns whether or not this device is likely a gamepad or a gamepad-
     * like device.
     * <p>
     * Essentially, a device is considered gamepad-like if it probably isn't
     * a keyboard and probably isn't a mouse.  This lumps together things
     * like wheels, rudders, joysticks, trackballs and gamepads as being
     * "gamepad-like" in that they all may serve a primary purpose that is
     * unrelated to the typical usage mode for a modern computing system.
     * This method may, in unusual circumstances, be incorrect.
     * <p>
     * The rules governing this process are fairly complex, and are described
     * in terms of a filter as follows:
     * <ol>
     * <li>Ask the controller what "type" it claims to be.</li>
     * <li>If it claims to be a gamepad, assume that it isn't lying and
     *     return <code>true</code>.</li>
     * <li>If it claims to be a keyboard or a mouse, assume that it isn't
     *     lying and return <code>false</code>.</li>
     * <li>Ask the controller what it's "name" is and convert it to uppercase
     *     in the locale of the host.</li>
     * <li>If the name contains the substring "KEYBOARD" or "MOUSE" assume
     *     that the device is a keyboard or mouse respectively and return
     *     <code>false</code>.</li>
     * <li>If the name contains the substring "RECEIVER" assume
     *     that the device is a communications helper and return
     *     <code>false</code>.</li>
     * <li>Check if it has rumblers.  If it does, assume that no sane
     *     manufacturer includes a rumbler in a keyboard or mouse and
     *     return <code>true</code>.</li>
     * <li>Get the names of every single control in the controller and
     *     convert to uppercase in the locale of the host.</li>
     * <li>If the names are a superset of all 26 English letters, assume
     *     it is a keyboard and return <code>false</code>.</li?
     * <li>If the names are a superset of {F1,F2,F3,F4,F5,F6,F7,F8}
     *     <em>and</em> there are at least 50 controls in the controller,
     *     assume it is a non-English keyboard and return
     *     <code>false</code>.</li>
     * <li>Anything making it this far is probably not a keyboard nor a mouse,
     *     so return <code>true</code>.</li>
     * </ol>
     * <p>
     * Because the logic for determining whether or not a controller is
     * gamepad-like is potentially complex and expensive to compute, it is
     * cached.  Subsequent calls will generally be much faster.
     * 
     * @param controller the controller to test
     * @return <code>true</code> if it is very likely that this controller
     * is a gamepad or gamepad-like device; otherwise, <code>false</code>
     */
    public final boolean isGamepadLike()
    {
        return gamepadLike;
    }

    /**
     * Generates a fingerprint for this kind of controller.
     * <p>
     * The fingerprint should be the same every time the same controller is
     * present, even between runs, provided that there are no changes to
     * drivers or support libraries.  It should also be the same regardless
     * of which individual <em>phsyical controller</em> is plugged in so
     * long as it is identical to others of its type.  For example, if you
     * plug in one XBOX360 controller, it should have the same fingerprint
     * code as every other XBOX360 controller of the same hardware revision.
     * <p>
     * Note that this is <em>not</em> a hashcode.  It does <em>not</em>
     * uniquely identify an individual piece of hardware.
     * 
     * @return the fingerprint for this kind of controller
     */
    private final int generateFingerprint()
    {
        int result = 37;
        String controllerName = getDeclaredName();
        result += 37 * (controllerName == null?
                0 : controllerName.hashCode());
        for (NiceControl control : getControls())
        {
            result += 37 * control.getFingerprint();
        }
        return result;
    }

    // ========================================================================
    // Static helper methods
    // ========================================================================

    /**
     * Returns a list of all controllers regardless of their type.
     * 
     * @return such a list, possibly of length 0 but never <code>null</code>
     */
    public final static List<NiceController> getAllControllers()
    {
        List<NiceController> allControllers = new ArrayList<NiceController>();
        for (Controller controller :
            ControllerEnvironment.getDefaultEnvironment().getControllers())
        {
            allControllers.add(getInstance(controller));
        }
        return allControllers;
    }

    /**
     * Returns all of the gamepads or gamepad-like devices attached to the
     * system.
     * <p>
     * This method scans the system for all controllers, locates those that
     * are probably gamepads (or gamepad-like), and returns them.
     * <p>
     * For details on exactly what constitutes a gamepad-like device,
     * see {@link #isGamepadLike()}.
     * 
     * @return a list of all gamepads (or gamepad-like devices, if requested)
     * attached to the system, possibly of length zero but never
     * <code>null</code>
     */
    public final static List<NiceController> getAllGamepads()
    {
        List<NiceController> allGamepads = new ArrayList<NiceController>();
        for (NiceController controller : getAllControllers())
        {
            if (controller.isGamepadLike())
            {
                allGamepads.add(controller);
            }
        }
        return allGamepads;
    }

    /**
     * Returns the first gamepad-like device found on the system.
     * <p>
     * This method scans the system for all known gamepads (or gamepad-like)
     * and returns the first one found.
     * 
     * @return the first gamepad-like device found, if any;
     * otherwise, <code>null</code>
     */
    final static NiceController getDefaultGamepad()
    {
        List<NiceController> allGamepads = getAllGamepads();
        if (allGamepads.size() > 0)
        {
            return allGamepads.get(0);
        }
        return null;
    }

    /**
     * Returns the current immutable configuration for this controller.
     * 
     * @return the current configuration for the controller
     */
    public final ControllerConfiguration getConfiguration() {
        return config;
    }

    /**
     * Sets the configuration used for this controller.  This change takes
     * effect immediately.
     * 
     * @param config the configuration to set.
     */
    public final void setConfiguration(final ControllerConfiguration config) {
        this.config = config;
    }



    /**
     * Polls all controls for the latest information immediately, and places
     * the information into the specified state object.
     * 
     * @param state the state to place the polled values into
     * @throws ControllerException if the controller fails to poll
     * successfully; this usually indicates that the controller has been
     * disconnected or has stopped functioning.
     */
    final void pollAllControls(ControllerState state)
    throws ControllerException
    {
        // Only allow one polling event to occur at any time as we do not
        // know how the hardware could react if we made two overlapping
        // requests.  This is a safety precaution.
        synchronized(pollingLock)
        {
            boolean ok = jinputController.poll();
            long pollingTime = System.currentTimeMillis();
            if (ok)
            {
                for (NiceControl control : getControls())
                {
                    control.poll(state.getControlState(control), pollingTime);
                }
            }
            else
            {
                throw new ControllerException("Controller polling has failed.");
            }
        }
    }
}