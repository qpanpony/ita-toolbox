package ita.listeningTestGUI;

import java.awt.event.WindowAdapter;
import java.awt.event.WindowEvent;

public class OpenGLWindowAdapter extends WindowAdapter 
{
	private ListeningTestMain parent;
	
	public OpenGLWindowAdapter(ListeningTestMain ltm)
	{
		parent = ltm;
	}
	
    @Override
    public void windowClosing(WindowEvent e) 
    {
    //	ControllerManager.shutdown();
    	parent.closeWindowEvent();
    	//e.getWindow().dispose();

    	//this is far from good.. only kill the system if the vm is not matlabs
    	String property = System.getProperty("java.vm.version");
    	if (property.equals("20.8-b03") || property.equals("24.45-b08"))
    	{
    		System.exit(0); //TODO: Don't call this from matlab
    	}
    }
}