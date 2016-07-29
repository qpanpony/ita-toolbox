package org.nicegamepads;

import java.util.HashSet;
import java.util.List;
import java.util.Set;

import org.nicegamepads.configuration.ControlConfiguration;
import org.nicegamepads.configuration.ControllerConfiguration;
import org.nicegamepads.configuration.ControllerConfigurationBuilder;
import org.nicegamepads.configuration.ControllerConfigurator;

public class VirtualAnalogStickTest
{
    public final static void main(String[] args)
    {
        ControllerManager.initialize();
        List<NiceController> gamepads = NiceController.getAllGamepads();

        NiceController controller = gamepads.get(0);
        System.out.println("gamepad: " + controller.getDeclaredName() + "; fingerprint=" + controller.getFingerprint());
        final ControllerConfigurationBuilder configBuilder = new ControllerConfigurationBuilder(controller);
        configBuilder.loadFrom(controller.getConfiguration());
        configBuilder.setAllAnalogDeadZones(-0.1f, 0.1f);
        configBuilder.setAllAnalogGranularities(0.1f);
        controller.setConfiguration(configBuilder.build());
        ControllerConfiguration config = controller.getConfiguration();
        System.out.println(config);

        ControllerConfigurator configurator = new ControllerConfigurator(controller);
        
        ControlEvent event = null;
        Set<NiceControl> identifiedControls = new HashSet<NiceControl>();
        NiceControl eastWest = null;
        HorizontalOrientation eastWestOrientation = null;
        NiceControl northSouth = null;
        VerticalOrientation northSouthOrientation = null;
        try
        {
            ControlConfiguration controlConfig = null;

            // East-west
            System.out.println("Identify east-west axis by pushing east...");
            event = configurator.identifyControl(NiceControlType.CONTINUOUS_INPUT, identifiedControls);
            System.out.println("Control identified: " + event);
            controlConfig = config.getConfiguration(event.sourceControl);
            identifiedControls.add(event.sourceControl);
            eastWest = event.sourceControl;
            if (event.previousValue > 0)
            {
                // Normal orientation
                eastWestOrientation = HorizontalOrientation.EAST_POSITIVE;
            }
            else
            {
                eastWestOrientation = HorizontalOrientation.WEST_POSITIVE;
            }

            // North-south
            System.out.println("Identify north-south axis by pushing south ...");
            event = configurator.identifyControl(NiceControlType.CONTINUOUS_INPUT, identifiedControls);
            System.out.println("Control identified: " + event);
            controlConfig = config.getConfiguration(event.sourceControl);
            identifiedControls.add(event.sourceControl);
            northSouth = event.sourceControl;
            if (event.previousValue > 0)
            {
                // Normal orientation
                northSouthOrientation = VerticalOrientation.SOUTH_POSITIVE;
            }
            else
            {
                northSouthOrientation = VerticalOrientation.NORTH_POSITIVE;
            }
        }
        catch (InterruptedException e)
        {
            e.printStackTrace();
        }

        ControllerPoller poller = ControllerPoller.getInstance(controller);
        
        //final ControllerConfiguration staticConfig = config;
        final VirtualAnalogStick virtualStick = new VirtualAnalogStick(
                VirtualAnalogStick.PhysicalConstraints.CIRCULAR,
                eastWest, northSouth,
                eastWestOrientation, northSouthOrientation);

        poller.addControllerPollingListener(new ControllerPollingListener(){
            @Override
            public void controllerPolled(ControllerState controllerState)
            {
                final BoundedVector vector = virtualStick.process(controllerState);
                System.out.println("Virtual stick: degrees=" + vector.getDirectionCompassDegrees() + ", magnitude=" + vector.getMagnitude());
            }
        });

        // Wait forever...
        System.out.println("Waiting for input.");
    }
}
