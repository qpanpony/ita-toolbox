package ita.listeningTestGUI;

public class MarkedStruct {
    //TODO: get/set for this
	public int isMarked = 0;
    public double markedElevation = 0;
    public double markedAzimuth = 0;
    public int fieldWidth = 1;
    public int additionalMarkWidth = 0;
    
    public MarkedStruct()
    {
    	
    }
    
    public MarkedStruct(MarkedStruct copyStruct)
    {
    	isMarked = copyStruct.isMarked;
    	markedElevation = copyStruct.markedElevation;
    	markedAzimuth = copyStruct.markedAzimuth;
    	fieldWidth = copyStruct.fieldWidth;
    	additionalMarkWidth = copyStruct.additionalMarkWidth;
    }
    
    
    public void reset()
    {
    	isMarked = 0;
    	markedElevation = 0;
    	markedAzimuth = 0;
    }
    
    public void mark(double azimuth, double elevation)
    {
    	isMarked = 1;
    	markedAzimuth = azimuth%360;
    	if (markedAzimuth < 0)
    	{
    		markedAzimuth = markedAzimuth+ 360;
    	}
    	markedElevation = elevation%180;
    }
    
    public void setFieldWidth(int value)
    {
    	fieldWidth = Math.abs(value);
    	// some trouble with even field with (how to position around given angles)
    	// just let someone who really needs it worry about it
    	if (fieldWidth%2 == 0)
    	{
    		fieldWidth+=1;
    		System.out.println("Uneven field width not supportet. Correcting to next higher number");
    	}
    	
    }
    
    public int checkMarked(double azimuth, double elevation)
    {
    	if (isMarked == 0)
    	{
    		return 0;
    	}
		if (isWithinMarkedArea(azimuth, elevation) == 0)
    	//if ( (azimuth != markedAzimuth) || (elevation != markedElevation))
		{
			return 0;
		}
		
    	return 1;
    }
    
    
    public int isWithinAzimuthArea(double azimuth)
    {
    	if (((markedAzimuth-Math.ceil(fieldWidth/2)) <= azimuth) && ((markedAzimuth+Math.floor(fieldWidth/2)) >= azimuth))
    	{
    		return 1;
    	}
    	return 0;
    }
    
    public int isWithinArea(double azimuth,double elevation)
    {
    	if (((markedAzimuth-Math.ceil(fieldWidth/2)) <= azimuth) && ((markedAzimuth+Math.floor(fieldWidth/2)) >= azimuth))
    	{
        	if (((markedElevation-Math.ceil(fieldWidth/2)) <= elevation) && ((markedElevation+Math.floor(fieldWidth/2)) >= elevation))
        	{
        		return 1;
        	}
    	}
	
    	return 0;
    }

    public int isWithinMarkedArea(double azimuth, double elevation)
    {
    	/*
    	double fieldCeil = Math.ceil(additionalMarkWidth/2) + Math.ceil(fieldWidth/2);
    	double fieldFloor = Math.floor(additionalMarkWidth/2) + Math.floor(fieldWidth/2);
    	if (( (markedAzimuth-fieldCeil) <= azimuth ) && ( (markedAzimuth+fieldFloor) >= azimuth ))
    	{
        	if (( (markedElevation-fieldCeil) <= elevation ) && ( (markedElevation+fieldFloor) >= elevation ))
        	{
        		return 1;
        	}
    	}
    	*/
    	double maxDistance = Math.floor(additionalMarkWidth/2) + Math.floor(fieldWidth/2);
    	
    	double azimuthDistance = Math.abs(markedAzimuth-azimuth);
    	double elevationDistance = Math.abs(markedElevation-elevation);
    	
    	if (azimuthDistance > 180)
    	{
    		azimuthDistance = 360-azimuthDistance;
    	}
    	
    	
    	if (( azimuthDistance <= maxDistance ) && (elevationDistance <= maxDistance ))
    	{        	
        	return 1;        	
    	}
    	
    	
	
    	return 0;
    }
    
	public void setAdditionalMarkWidth(int value) 
	{
		// TODO Auto-generated method stub
		additionalMarkWidth = value;
	}
	
}

