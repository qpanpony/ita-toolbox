package org.nicegamepads;

import java.util.List;

import org.nicegamepads.configuration.ControllerConfiguration;
import org.nicegamepads.configuration.ControllerConfigurationBuilder;
import org.nicegamepads.configuration.ControllerConfigurator;


public class ControllerCalibrationTest
{
    public final static void main(String[] args)
    {
        ControllerManager.initialize();
        List<NiceController> gamepads = NiceController.getAllGamepads();
        for (NiceController controller : gamepads)
        {
            System.out.println("gamepad: " + controller.getDeclaredName() + "; fingerprint=" + controller.getFingerprint());
        }

        NiceController controller = gamepads.get(0);
        ControllerConfiguration config = new ControllerConfigurationBuilder(controller).build();
        System.out.println(config);
        ControllerConfigurator configurator = new ControllerConfigurator(controller, config);

        configurator.addCalibrationListener(new CalibrationListener(){

            @Override
            public void calibrationResultsUpdated(NiceController controller,
                    NiceControl control, Range range)
            {
                System.out.println("Calibration updated for controller \""
                        + controller + "\", control \""
                        + control.getDeclaredName() + "\": "
                        + range);
            }

            @Override
            public void calibrationStarted(NiceController controller)
            {
                System.out.println("Calibration started for controller \""
                        + controller + "\"");
            }

            @Override
            public void calibrationStopped(NiceController controller,
                    CalibrationResults results)
            {
                System.out.println("Calibration complete for controller \""
                        + controller + "\":");
                System.out.println(results);
            }
        });

        System.out.println("Asking calibration to start.");
        configurator.startCalibrating();
        try
        {
            System.out.println("Waiting for 30 seconds.");
            synchronized(configurator)
            {
                configurator.wait(30000L);
            }
        }
        catch (InterruptedException e)
        {
            e.printStackTrace();
        }
        System.out.println("Asking calibration to stop.");
        configurator.stopCalibrating();
        ControllerManager.shutdown();
    }
}
