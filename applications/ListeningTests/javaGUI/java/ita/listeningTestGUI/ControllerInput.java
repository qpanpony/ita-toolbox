package ita.listeningTestGUI;

import java.util.List;

import org.nicegamepads.ControlChangeListener;
import org.nicegamepads.ControlEvent;
import org.nicegamepads.NiceControl;
import org.nicegamepads.NiceControlType;
import org.nicegamepads.NiceController;

public class ControllerInput extends abstractInput implements ControlChangeListener
{
	public ControllerInput(InputEvent event) {
		super(event);
		// TODO Auto-generated constructor stub
	}

	NiceControl xAxisControl = null;
	NiceControl yAxisControl = null;
	NiceControl buttonControl = null;
	
	private float xAxisValue = 0;
	private float yAxisValue = 0;
	private float elevationValue = 90;
	
	private int debugController = 1;
	
	private ControllerInput_keymap controllerKeymap;
	public void setController(NiceController controller)
	{
		String osString =  System.getProperty("os.name");
		if (osString.equals("Linux"))
		{
			controllerKeymap = new ControllerInput_keymap_linux_ps3();
		}
		else
		{
			controllerKeymap = new ControllerInput_keymap_windows();
		}
		// get all axis controller:
		elevationDirection = 90;
		List<NiceControl> controlList = controller.getControlsByType(NiceControlType.CONTINUOUS_INPUT);
		for (NiceControl listControl : controlList)
		{
//			System.out.println(listControl.getDeclaredName());
//			System.out.println(listControl.getFingerprint());
			switch (listControl.getFingerprint())
			{
				case 402811189:	//Button 2
					buttonControl = listControl;
					break;
				case 1663653298: // X-Axis
					xAxisControl = listControl;
					break;
				case 1916558489:	// Y-Axis
					yAxisControl = listControl;
					break;
				default:
					break;
			}
		}
		
		// get rumble
		controlList = controller.getControlsByType(NiceControlType.FEEDBACK);
		for (NiceControl listControl : controlList)
		{
			System.out.println(listControl.getDeclaredName());
			System.out.println(listControl.getFingerprint());
		}
		
	}
	@Override
	public void valueChanged(ControlEvent event) {
		// TODO Auto-generated method stub
		if (debugController == 1)
		{
			System.out.println(event.toString());
			System.out.println(event.sourceControl.getDeclaredName());
			System.out.println(event.sourceControl.getFingerprint());
			System.out.println(event.currentValue);
		}
		
		int fingerprint = event.sourceControl.getFingerprint();
		
		if (fingerprint == controllerKeymap.getStartButton())
		{
			// start
			inEvent.startEvent();
		}
		else if (fingerprint == controllerKeymap.getaButton())
		{
			// a 
			sendButtonEvent(event.currentValue);
		}
		else if (fingerprint == controllerKeymap.getxButton())
		{
			changePerspectiveEvent(event.currentValue);
		}
		else if (fingerprint == controllerKeymap.getbButton())
		{
			replayButtonEvent(event.currentValue);
		}
		else if (fingerprint == controllerKeymap.getxAxis())
		{
			xAxisEvent(event);
		}
		else if (fingerprint == controllerKeymap.getyAxis())
		{
			yAxisEvent(event);
		}
		else if (fingerprint == controllerKeymap.getzAxis())
		{
			zAxisEvent(event);
		}
		else if (fingerprint == controllerKeymap.getzRotation())
		{
			zRotationEvent(event);
		}	
	}
	
	private void xAxisEvent(ControlEvent event) 
	{
		xAxisValue = event.currentValue;
//		System.out.println(xAxisValue);
		double testValue = Math.atan2(xAxisValue, yAxisValue);
		azimuthDirection = testValue *180/Math.PI + 180;
		azimuthMagnitude = Math.sqrt(Math.pow(xAxisValue, 2)+ Math.pow(yAxisValue, 2));
//		System.out.println(testValue);
	}
	
	private void yAxisEvent(ControlEvent event) 
	{
		yAxisValue = event.currentValue;
		double testValue = Math.atan2(xAxisValue, yAxisValue);
		azimuthDirection = testValue *180/Math.PI + 180;
		azimuthMagnitude = Math.sqrt(Math.pow(xAxisValue, 2)+ Math.pow(yAxisValue, 2));
	}
	
	private void zRotationEvent(ControlEvent event)
	{
		// round elevation value to avoid slow elevation drift
		// the value is rounded to the first decimal (*10 /10)
		float tmp = event.currentValue*10;
		tmp = Math.round(tmp);
		tmp = tmp/10;
		elevationValue = tmp;
	}
	
	public double getElevationDirection()
	{
		elevationDirection = elevationDirection + elevationValue;
//		if ((tempValue >= 0) && (tempValue <=180))
//		{
//			elevationDirection = tempValue;
//		}
		
		if (elevationDirection > upperElevationLimit)
		{
			elevationDirection = upperElevationLimit;
		}
		
		if (elevationDirection < lowerElevationLimit)
		{
			elevationDirection = lowerElevationLimit;
		}
		
		return elevationDirection;
	}
	
	private void zAxisEvent(ControlEvent event) 
	{
		
	}
	
	private void sendButtonEvent(float value)
	{
		if (value == 1)
		{
			inEvent.sendButtonEvent(getAzimuthDirection(), getElevationDirection(), getAzimuthMagnitude());
			//events.notifyMousePressEvent(azimuthDirection,elevationValue);
		}
	}
	
	private void replayButtonEvent(float value)
	{
		if (value == 1)
		{
			inEvent.replayEvent();
		}
	}
	
	private void changePerspectiveEvent(float value) 
	{
		if (value == 1)
		{
			inEvent.changePerspectiveEvent();
		}
	}
	

}
