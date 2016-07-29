package ita.listeningTestGUI;

// this class supplies an event wrapper into matlab
// each public function in the MyTestListener Class will appear as a callback in the matlab version of this object
// additionally, each callback will have a data field that is set in the notify function
// most of this is taken from http://undocumentedmatlab.com/blog/matlab-callbacks-for-java-events/
public class MatlabEventWrapper
{
	private boolean isBlocked = false;
	private boolean isStartBlocked = false;

	private static MatlabEventWrapper instance;
	//make the class a singleton
	private MatlabEventWrapper () {}
	public static MatlabEventWrapper getInstance() 
	{
	    if (MatlabEventWrapper.instance == null) 
	    {
	    	MatlabEventWrapper.instance = new MatlabEventWrapper();
	    }
	    return MatlabEventWrapper.instance;
	}
	
	public boolean isBlocked() {
		return isBlocked;
	}
	public void setBlocked(boolean isBlocked) {
		this.isBlocked = isBlocked;
	}

    public boolean isStartBlocked() {
		return isStartBlocked;
	}
	public void setStartBlocked(boolean isStartBlocked) {
		this.isStartBlocked = isStartBlocked;
	}
	

	private java.util.Vector data = new java.util.Vector();
    public synchronized void addMyTestListener(MyTestListener lis) {
        data.addElement(lis);
    }
    public synchronized void removeMyTestListener(MyTestListener lis) {
        data.removeElement(lis);
    }
    public interface MyTestListener extends java.util.EventListener {
        void confirmationEvent(ConfirmationEvent event);
        void startEvent(ConfirmationEvent event);
        void replayEvent(ConfirmationEvent event);
        void windowCloseEvent(ConfirmationEvent event);
    }

    
    public class ConfirmationEvent extends java.util.EventObject {
        private static final long serialVersionUID = 1L;
        public double azimuth,elevation;
		public int inHeadLocalization;        
        ConfirmationEvent(Object obj, double azimuth, double elevation, int inHeadLocalization) {
            super(obj);
            this.azimuth = azimuth;
            this.elevation = elevation;
            this.inHeadLocalization = inHeadLocalization;
        }
    }
    
    public void notifyMousePressEvent(double azimuth, double elevation, int inHeadLocalization) {
    	java.util.Vector dataCopy;
        synchronized(this) {
            dataCopy = (java.util.Vector)data.clone();
        }
        for (int i=0; i < dataCopy.size(); i++) {
        	ConfirmationEvent event = new ConfirmationEvent(this, azimuth, elevation, inHeadLocalization);
            ((MyTestListener)dataCopy.elementAt(i)).confirmationEvent(event);
        }
    }

    
    public void notifyStartEvent() 
    {
        java.util.Vector dataCopy;
        synchronized(this) {
            dataCopy = (java.util.Vector)data.clone();
        }
        for (int i=0; i < dataCopy.size(); i++) {
        	ConfirmationEvent event = new ConfirmationEvent(this, -1, -1, -1);
            ((MyTestListener)dataCopy.elementAt(i)).startEvent(event);
        }
    }
    
    public void notifyReplayEvent() {
        java.util.Vector dataCopy;
        synchronized(this) {
            dataCopy = (java.util.Vector)data.clone();
        }
        for (int i=0; i < dataCopy.size(); i++) {
        	ConfirmationEvent event = new ConfirmationEvent(this, 0, 0, 0);
            ((MyTestListener)dataCopy.elementAt(i)).replayEvent(event);
        }
    }
    
    public void notifyWindowCloseEvent() {
        java.util.Vector dataCopy;
        synchronized(this) {
            dataCopy = (java.util.Vector)data.clone();
        }
        for (int i=0; i < dataCopy.size(); i++) {
        	ConfirmationEvent event = new ConfirmationEvent(this, 0, 0, 0);
            ((MyTestListener)dataCopy.elementAt(i)).windowCloseEvent(event);
        }
    }
    
}