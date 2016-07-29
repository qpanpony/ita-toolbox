package ita.listeningTestGUI;

public abstract class ControllerInput_keymap {
	
	static protected int controllerFingerprint = 0;
	protected int startButton = 0;
	protected int aButton = 0;
	protected int bButton = 0;
	protected int xButton = 0;
	protected int yButton = 0;
	protected int xAxis = 0;
	protected int yAxis = 0;
	protected int zAxis = 0;
	protected int zRotation = 0;
	
	protected int lbButton = 0;
	protected int rbButton = 0;
	protected int ltButton = 0;
	protected int rtButton = 0;
	
	
	
	public int getStartButton() {
		return startButton;
	}
	public int getaButton() {
		return aButton;
	}
	public int getbButton() {
		return bButton;
	}
	public int getxButton() {
		return xButton;
	}
	public int getyButton() {
		return yButton;
	}
	public int getxAxis() {
		return xAxis;
	}
	public int getyAxis() {
		return yAxis;
	}
	public int getzAxis() {
		return zAxis;
	}
	public int getzRotation() {
		return zRotation;
	}

	public int getLbButton() {
		return lbButton;
	}
	public int getRbButton() {
		return rbButton;
	}
	public int getLtButton() {
		return ltButton;
	}
	public int getRtButton() {
		return rtButton;
	}
	
	static public int getFingerprint(){
		return controllerFingerprint;
	}
	
}
