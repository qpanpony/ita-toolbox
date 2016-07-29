package ita.listeningTestGUI;

import java.awt.event.WindowEvent;
import java.util.List;

import org.nicegamepads.ControllerManager;
import org.nicegamepads.ControllerPoller;
import org.nicegamepads.NiceController;

/**
 * This is the main class. The class manages the input and the opengl output. 
 * Additionally, the MatlabEventWrapper is handled here
 * This class implements InputEvent to handle input events (sendButtonEvent etc)
 */
public class ListeningTestMain implements InputEvent {

	// workaround. this is the fingerprint of the used gamepad
	// if this fingerprint is missing -> fallback to keyboard mode
	
	//Franks kleines schwarzes
	//private int controllerFingerprint = 522412925;
	
	//Logitech F710 (USE THIS IN D MODE)
	private NiceController myController = null;
	private int controllerFingerprint =  0;

			
	// the input object (either controller, or keyboard)
	private abstractInput inputObject;
	// help variable. there is a better way to handle this
	private int useKeyboard = 0;
	
	// the open gl window
	private MainGLWindowBasis mainWindow = null;
	
	// this is set after the first input to start training/whatever
	private int isStarted = 0;
	
	// the default mode (
	private static int defaultOpenGLMode = 0;
	
	// this is used to close the openglwindow
	private OpenGLWindowAdapter windowAdapter;
	
	private int elevationLowerLimit = 50;
	private int elevationUpperLimit = 130;
	
	private int fullScreenValue = 0;
	
	private int onlyFeedbackValue = 1;
	private int viewAngle = 0;
	
	@Override
	// this function is called in the inputclasses after a confirmation
	// it marks the selected area
	public void sendButtonEvent(double azimuth, double elevation, double magnitude) 
	{
		if (magnitude > 0.5)
		{
			mainWindow.markSelectedSection(azimuth, elevation,isStarted);
		}
		else
		{			
			mainWindow.markInHeadLocalization(1,isStarted);
		}
	}
	
	private static ListeningTestMain instance;
	//make the class a singleton
	private ListeningTestMain () 
	{
		windowAdapter = new OpenGLWindowAdapter(this) {
            public void windowClosing(WindowEvent ev) {
            	System.out.println("close window");
        		mainWindow.setVisible(false);
        		inputObject.getEventObject().notifyWindowCloseEvent();
                //frame.dispose();
            }
        };
        
		String osString =  System.getProperty("os.name");
		if (osString.equals("Linux"))
		{
			controllerFingerprint = ControllerInput_keymap_linux_ps3.getFingerprint();
		}
		else
		{
			controllerFingerprint = ControllerInput_keymap_windows.getFingerprint();
		}
        
		initInputDevice();
	}
	public static ListeningTestMain getInstance() 
	{
	    if (ListeningTestMain.instance == null) 
	    {
	    	ListeningTestMain.instance = new ListeningTestMain();
	    }
	    return ListeningTestMain.instance;
	}
	
	public void emergencyReset()
	{
		ListeningTestMain.instance = null;
	}
	
	public void show() {
		this.show(defaultOpenGLMode,".");
	}

	
	public void show(int openGLMode,String path)
	{
		if (mainWindow == null)
		{
			switch (openGLMode)
			{
				case 0:
					mainWindow = new BasisGLMode(inputObject,windowAdapter);
					break;
					
				case 1:
					mainWindow = new BlockGLMode(inputObject,windowAdapter);
					break;
			}
			
			if (useKeyboard == 1 && onlyFeedbackValue == 0)
			{
				mainWindow.getCanvas().addKeyListener((KeyboardInput) inputObject);
			}
			mainWindow.setOnlyFeebackValue(onlyFeedbackValue);
			mainWindow.setViewAngle(viewAngle);
			mainWindow.show(fullScreenValue,path);
			mainWindow.elevationLowerLimit = elevationLowerLimit;
			mainWindow.elevationUpperLimit = elevationUpperLimit;
			inputObject.setElevationLimits(elevationLowerLimit, elevationUpperLimit);
		}
		else
		{
			if (mainWindow.isVisible())
			{
				
			}
			else
			{
				mainWindow.setOnlyFeebackValue(onlyFeedbackValue);
				mainWindow.setViewAngle(viewAngle);
				initInputDevice();
				fullReset();
				mainWindow = new BasisGLMode(inputObject,windowAdapter);
				mainWindow.setOnlyFeebackValue(onlyFeedbackValue);
				mainWindow.setViewAngle(viewAngle);
				mainWindow.show(fullScreenValue,path);
				mainWindow.elevationLowerLimit = elevationLowerLimit;
				mainWindow.elevationUpperLimit = elevationUpperLimit;
				inputObject.setElevationLimits(elevationLowerLimit, elevationUpperLimit);
				
				if (useKeyboard == 1 && onlyFeedbackValue == 0)
				{
					mainWindow.getCanvas().addKeyListener((KeyboardInput) inputObject);
				}
				
			}
				
		}
		
	}
	
	public void setFullscreen(int value)
	{
		fullScreenValue = value;
		//mainWindow.setFullscreen(value);
		
	}
	
	
	public void setOnlyFeedback(int value)
	{
		onlyFeedbackValue = value;
	}
	
	public void setViewAzimuthAngle(int value)
	{
		viewAngle = value;
		if (mainWindow != null)
		{
			mainWindow.setViewAngle(viewAngle);
		}
		
	}
	
	// this does not work as i would like it to -> complications in matlab
	// because the framework does not shutdown correctly
	public static void shutdownController()
	{
		//ControllerManager.shutdownNow();
//		System.out.println("ListeningTest.shutdownController");
	}
	
	// deconstructor
	public void close()
	{
//		isStarted = 0;
//		System.out.println("ListeningTest.close");
//		if (null != mainWindow)
//		{
//			mainWindow.close();
//		}
//		inputObject = null;
//		mainWindow = null;
//		windowAdapter = null;
//		
//		if (null != myController)
//		{
////			System.out.println("ListeningTestMain.removeControllerPoller");
//			ControllerPoller poller = ControllerPoller.getInstance(myController);
//			poller.removeControlChangeListener((ControllerInput) inputObject);
//		}
//		shutdownController();
//		Runtime.getRuntime().gc();
		mainWindow.setVisible(false);
		
	}
	
	// inits the input method
	private void initInputDevice()
	{
    	// first: try controller
       	myController = null;
       	if (this.onlyFeedbackValue == 0)
		{
           	System.out.println("Init Controller...");
	       	if (ControllerManager.isTerminated() == true)
	       	{
	       		// shutdown does not work
	       		System.out.println("Controller still in shutdown. This will result in an error. Restart Matlab (sorry)");
	       	}
	       	else
	       	{
		       	// get all the controllers
		       	// unfortunately, mouse is also listed here.
		       	// look for a fingerprint match with our gamepad
		    	ControllerManager.initialize();
				List<NiceController> gamepads = NiceController.getAllGamepads();
				for (NiceController controller : gamepads)
				{
					if (controller.isGamepadLike())
					{
						System.out.println(controller.getDeclaredName());
						System.out.println(controller.getFingerprint());
						//System.out.println(controller.getDeclaredName());
						if (controller.getFingerprint() == controllerFingerprint)
						{
							myController = controller;
						}
					}
				}
	       	}
		}
		// if the controller is not found, use keyboard input
	    if (myController == null)
	    {
	    	// if no controller is found, fallback to keyboard
	    	System.out.println("No Controller. Fallback to keyboard mode -- This has not been updated in a while");
	    	
	    	KeyboardInput keyboardInp = new KeyboardInput(this);
	    	useKeyboard = 1;
	    	inputObject = keyboardInp;
	    }
	    else
	    {
	    	if (inputObject == null)
	    	{
		    	ControllerInput controllerListener = new ControllerInput(this);
				ControllerPoller poller = ControllerPoller.getInstance(myController);
		
				controllerListener.setController(myController);
				poller.addControlChangeListener(controllerListener);
				inputObject = controllerListener;
	    	}
			System.out.println("Init Controller complete");
			
	    }
    	
    }
	
	// return the matlab event wrapper (this only needs to be called from matlab)
    public MatlabEventWrapper getEventObject() {
        return inputObject.getEventObject();
    };
    
    // interface: sets a direction to train
    public void trainDirection(double azimuth, double elevation,int trainResolution)
    {
    	mainWindow.trainSection(azimuth, elevation,trainResolution);
    }

    // this function is used to interact the block mode with matlab
    // arrays of blockvalues are passed
    // the arrays have to be numberOfBlocks long
    // from the arrays, blocks are constructed. (the same index in every array is used in the same block)
    // you probably have to make sure that the lowest elevation comes first to avoid transparency layer issues
    public void setBlocks(int numberOfBlocks, float[] azimuthValues, float[] elevationValues, float[] blockWidth, float[] additionalWidth)
    {
    	mainWindow.setNewBlocks(numberOfBlocks, azimuthValues, elevationValues, blockWidth, additionalWidth);
    }
    
    
    public void setDynamicAlphaMode(int value)
    {
    	mainWindow.setDynamicAlphaMode(value);
    }
    
    // this event is used to hold the test until the user is ready
	public void startEvent() 
	{
		if (isStarted == 0)
		{
			isStarted = 1;
			mainWindow.setIsStarted(isStarted);
			inputObject.getEventObject().notifyStartEvent();
		}
	}
	
	public void reset()
	{
		mainWindow.reset();
		mainWindow.setHideReplayButton(0);
		mainWindow.showTrainMessage(0);
	}
	
	public void fullReset()
	{
		isStarted = 0;
		mainWindow.setIsStarted(isStarted);
		mainWindow.reset();
	}

	public void replayEvent() {
		if (isStarted == 1)
		{
			inputObject.getEventObject().notifyReplayEvent();
		}
	}
	
	public void hideReplayButton()
	{
		mainWindow.setHideReplayButton(1);
	}
	
	
	public void closeWindowEvent()
	{
		System.out.println("ListeningTestMain.closeEvent");
//		mainWindow.setVisible(false);
//		inputObject.getEventObject().notifyWindowCloseEvent();
		
	}

	@Override
	public void changePerspectiveEvent() 
	{
		mainWindow.changePerspective();
	}
	
	public void setControllerLimits(int lowerLimit, int upperLimit)
	{
		if (mainWindow == null)
		{
			elevationLowerLimit = lowerLimit;
			elevationUpperLimit = upperLimit;
		}
		else
		{
			elevationLowerLimit = lowerLimit;
			elevationUpperLimit = upperLimit;
			mainWindow.elevationLowerLimit = lowerLimit;
			mainWindow.elevationUpperLimit = upperLimit;
		}
		inputObject.setElevationLimits(lowerLimit, upperLimit);
	}
	
	public void setFeedback(double trainAzimuth, double trainElevation, int resolution, double userAzimuth, double userElevation)
	{
		mainWindow.trainSection(trainAzimuth, trainElevation,resolution);
		inputObject.setDirection(userAzimuth, userElevation);
	}
	
	public void finalize()
    {
    	System.out.println("ListeningTestMain.finalize");
    }
}
