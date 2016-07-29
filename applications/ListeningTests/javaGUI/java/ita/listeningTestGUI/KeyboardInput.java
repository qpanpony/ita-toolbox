package ita.listeningTestGUI;

import java.awt.event.KeyEvent;
import java.awt.event.KeyListener;

public class KeyboardInput extends abstractInput implements KeyListener
{

	public KeyboardInput(InputEvent event) {
		super(event);
		// TODO Auto-generated constructor stub
	}

	@Override
	public void keyPressed(KeyEvent e) {
		// TODO Auto-generated method stub
		
		// the magnitude is only used in controller setups. set it to 1
		if (azimuthMagnitude == 0)
		{
			inEvent.startEvent();
			azimuthMagnitude = 1;
		}
		switch (e.getKeyCode())
		{
			case 37: // left
				azimuthDirection += 1;
				break;
			case 38: // up
				if (elevationDirection > lowerElevationLimit)
				{
					elevationDirection -= 1;
				}
				break;
			case 39: // right
				azimuthDirection -= 1;
				break;
			case 40: // down
				if (elevationDirection < upperElevationLimit)
				{
					elevationDirection += 1;
				}
				break;
				
			case 10: // enter
				inEvent.sendButtonEvent(azimuthDirection, elevationDirection, azimuthMagnitude);
				//events.notifyMousePressEvent(azimuthDirection,elevationDirection);
				break;
				
		
		}
		
		elevationDirection = modulo(elevationDirection,180);
		azimuthDirection = modulo(azimuthDirection,360); 
	}

	@Override
	public void keyReleased(KeyEvent e) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void keyTyped(KeyEvent e) {
		// TODO Auto-generated method stub
		// arrow keys don't generate a keyTyped event
		//System.out.println(e.getKeyCode());
	}

	//java is stupid..
	public double modulo(double x, double modValue)
	{
		return ((x % modValue) + modValue) % modValue;
	}
	
}
