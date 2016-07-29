package ita.listeningTestGUI;

import java.awt.event.MouseEvent;
import java.awt.event.MouseListener;

import javax.media.opengl.awt.GLCanvas;




public class MouseInput extends abstractInput implements MouseListener
{
	public MouseInput(InputEvent event) {
		super(event);
		// TODO Auto-generated constructor stub
	}

	public int clickCounter = 0;

  
	@Override
	public void mouseClicked(MouseEvent arg0) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void mouseEntered(MouseEvent arg0) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void mouseExited(MouseEvent arg0) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void mousePressed(MouseEvent arg0) {
		// TODO Auto-generated method stub
		clickCounter += 1;
		GLCanvas canvas =  (GLCanvas) arg0.getSource();
		canvas.repaint();
	
		System.out.print(arg0.getButton());
		events.notifyMousePressEvent(azimuthDirection,elevationDirection, 0);
		//setting inHeadLocalization to 0 could cause troubles here
	}

	@Override
	public void mouseReleased(MouseEvent arg0) {
		// TODO Auto-generated method stub
		
	};
   
}




