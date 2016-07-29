package org.nicegamepads;

import java.util.List;

public class GamepadEnumerationTest
{
    public final static void main(String[] args)
    {
        ControllerManager.initialize();
        List<NiceController> gamepads = NiceController.getAllControllers();
        for (NiceController controller : gamepads)
        {
            System.out.println("controller: " + controller.getDeclaredName() + "; isGamepadLike=" + controller.isGamepadLike() + "; fingerprint=" + controller.getFingerprint());
        }
        ControllerManager.shutdown();
    }
}
