package ita.listeningTestGUI;

public interface InputEvent 
{
	public void sendButtonEvent(double azimuth, double elevation, double magnitude);
	public void startEvent();
	public void replayEvent();
	public void changePerspectiveEvent();
}
