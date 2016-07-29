package ita.listeningTestGUI;



public abstract class abstractInput {

	protected double azimuthDirection = 0;
	protected double azimuthMagnitude = 0;
	protected double elevationDirection = 90;
	
	protected double lowerElevationLimit = 0;
	protected double upperElevationLimit = 180;
	protected InputEvent inEvent;
	
	protected int invertedPerspective = 0;
	protected MatlabEventWrapper events = MatlabEventWrapper.getInstance();
	
	public void setElevationLimits(double lowerLimit, double upperLimit)
	{
		lowerElevationLimit = lowerLimit;
		upperElevationLimit = upperLimit;
	}
	
	public abstractInput(InputEvent event)
	{
		inEvent = event;
	}
	
	public double getAzimuthDirection()
	{
		if (invertedPerspective == 1)
		{
			return (azimuthDirection+180)% 360;
		}
		return azimuthDirection;
	}
	
	public double getAzimuthMagnitude()
	{
		return azimuthMagnitude;
	}
	
	public double getElevationDirection()
	{
		return elevationDirection;
	}
	
	MatlabEventWrapper getEventObject()
	{
		return events;
	}
	
	public void setInvertedPerspective(int value)
	{
		invertedPerspective = value;
	}
	
	public void setDirection(double azimuth, double elevation)
	{
		azimuthDirection = azimuth;
		elevationDirection = elevation;
		azimuthMagnitude = 1;
	}
	
	
	public void reset()
	{
		azimuthDirection = 0;
		azimuthMagnitude = 0;
		elevationDirection = 90;
		invertedPerspective = 0;
	}
    
	public void finalize()
    {
    	System.out.println("abstractInput.finalize");
    }
	
}
