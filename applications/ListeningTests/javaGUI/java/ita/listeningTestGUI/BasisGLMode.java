package ita.listeningTestGUI;
// import java.awt.Frame;

import javax.media.opengl.GL;
import javax.media.opengl.GL2;
import javax.media.opengl.GLAutoDrawable;

import static javax.media.opengl.GL.*; // GL constants
import static javax.media.opengl.GL2.*; // GL2 constants

public class BasisGLMode extends MainGLWindowBasis{

	public BasisGLMode(abstractInput inputOb, OpenGLWindowAdapter wA)
	{
		super(inputOb,wA);
	       
    	//set the elevation limits to the controller
   		inputObject.setElevationLimits(elevationLowerLimit, elevationUpperLimit);
    };
    
    // the main display function
    public void display(GLAutoDrawable drawable) {
    	
    	// get the current state from the input device
    	double azimuth = inputObject.getAzimuthDirection();
    	double magnitude = inputObject.getAzimuthMagnitude();
    	double elevation = inputObject.getElevationDirection();

//    	if (perspective == 180)
//    	{
//    		azimuth = (azimuth + 180) % 360;
//    	}
    	
    	GL2 gl = drawable.getGL().getGL2();
    	// Clear the color and the depth buffers
    	gl.glClear(GL.GL_COLOR_BUFFER_BIT | GL.GL_DEPTH_BUFFER_BIT);
//


//    	// rotate the view to look from behind and slightly above horizontal axis
//    	
    	gl.glLoadIdentity();                // reset the current model-view matrix
    	gl.glTranslatef(0f, 0.0f, -7.0f);
    	gl.glRotatef(60, -1.0f, 0.0f, 0.0f); // rotate about the x, y and z-axes
    	gl.glRotatef(90+viewAngle, 0.0f, 0.0f, 1.0f); // rotate about the x, y and z-axes
    	gl.glRotatef(perspective, 0, 0, 1f);
    	
    	
//
//    	
    	drawBackground(drawable,azimuth,magnitude);
    	drawHelperSphere(drawable,azimuth,elevation,magnitude);
		double azimuthMod = (azimuth*10)%1;
		double realAzimuth = azimuth-azimuthMod/10;
		azimuthMod = elevation%1;
		double realElevation = elevation - azimuthMod;
//    	
//
//		
//    	// if the input is active, display the crosshair
    	if (magnitude > 0.5)
    	{
    		drawSpherePart(drawable, radius, 1, 1, realAzimuth, realAzimuth+1, realElevation-10, realElevation + 10,searchColor,GL_LINE,1);
    		drawSpherePart(drawable, radius, 1, 1, realAzimuth-10, realAzimuth+10, realElevation, realElevation + 1,searchColor,GL_LINE,1);
    	}
    	
    	double markedAzimuth = 0;
    	double markedElevation = 0;
    	//one button press marks the selected area. another will submit
    	if ( (isMarked.isMarked == 1) && (inHeadLocalization == 0) ) 
    	{
    		double directionMod = (isMarked.markedAzimuth*10)%1;
    		markedAzimuth = isMarked.markedAzimuth-directionMod/10;
    		directionMod = isMarked.markedElevation%1;
    		markedElevation = isMarked.markedElevation - directionMod;
    		
    		ColorClass color = markedColor;
    		if (isMarked.isWithinArea(realAzimuth, realElevation) == 1)
    		{

    			color = markedAndSelectedColor;
    		}
    		
    		drawSpherePart(drawable, radius, 1, 1, markedAzimuth, markedAzimuth+1, markedElevation, markedElevation + 1,color,GL_FILL,1);

    	}
    	
    	if (trainSection.isMarked == 1)
    	{
    		double directionMod = (trainSection.markedAzimuth*10)%1;
    		double newAzimuth = trainSection.markedAzimuth-directionMod/10;
    		directionMod = trainSection.markedElevation%1;
    		double newElevation = trainSection.markedElevation - directionMod;
    		double width = trainSection.fieldWidth;
        	
    		ColorClass color = trainColor;
    		if ( (trainSection.isWithinArea(realAzimuth, realElevation) == 1)  && (magnitude > 0.5) ) 
    		{
    			color = trainAndSelectedColor;
    		}
    		
    		if ((isMarked.isMarked == 1) && (trainSection.isWithinMarkedArea(markedAzimuth, markedElevation) == 1))
    		{
    			color = markedColor;
    		}
    		
    		if ((isMarked.isMarked == 1) && (trainSection.isWithinMarkedArea(markedAzimuth, markedElevation) == 1) && (trainSection.isWithinMarkedArea(realAzimuth, realElevation) == 1))
    		{
    			color = markedAndSelectedColor;
    		}
    		
    		drawSpherePart(drawable, radius, 1, 1, newAzimuth-Math.floor(width/2), newAzimuth+Math.ceil(width/2), newElevation-Math.floor(width/2), newElevation + Math.ceil(width/2),color,GL_FILL,1);
    	}
    	
    	if (onlyFeedbackValue == 0)
    	{
    		drawOverlay(drawable);
    	}
    	
        // check OpenGL error
//        int errorNumber = gl.glGetError();
//        String errorString = glu.gluErrorString(errorNumber);
//        System.out.println(errorNumber);
//        System.out.println(errorString);

    	gl.glFlush();
    	
    	
    }

    protected void drawBackground(GLAutoDrawable drawable,double azimuth,double magnitude)
    {
//    	super.drawBackground(drawable, azimuth, magnitude);
    	drawFullArrow(drawable,1);
    	drawCircleLinePart(drawable, radius, 5, 90,0,360,searchColor);
//    	drawCircleLinePart(drawable, radius, 10, inputObject.upperElevationLimit,0,360,searchColor);
//    	drawCircleLinePart(drawable, radius, 10, inputObject.lowerElevationLimit,0,360,searchColor);
    	
    }
    
	private void drawHelperSphere(GLAutoDrawable drawable, double azimuth,
			double elevation, double magnitude) 
	{
		drawHorizontalCircleLine(drawable,radius,5,90+viewAngle,elevationLowerLimit,elevationUpperLimit,searchColor);
		//drawText(drawable,radius,90,90,"90�");
		drawHorizontalCircleLine(drawable,radius,5,270+viewAngle,elevationLowerLimit,elevationUpperLimit,searchColor);
		//drawText(drawable,radius,270,90,"-90�");
		if (this.onlyFeedbackValue == 0)
		{
			if ( ((azimuth > 315 ) || (azimuth <= 0)) || (magnitude < 0.5))
			{
				drawSpherePart(drawable, radius, 5, 5, -50, 5, elevationLowerLimit, elevationUpperLimit, backgroundColor,GL_LINE,0);
				drawHorizontalCircleLine(drawable,radius,5,330,elevationLowerLimit,elevationUpperLimit,searchColor);
				drawHorizontalCircleLine(drawable,radius,5,0,elevationLowerLimit,elevationUpperLimit,searchColor);
				for (int index = elevationLowerLimit+15-elevationLowerLimit%15; index <= elevationUpperLimit; index = index + 15)
				{
					drawCircleLinePart(drawable, radius, 5, index,-50,5,searchColor);		
				}
	
			}
			else if ( ((azimuth > 0 ) && (azimuth <= 45)) )
			{
				drawSpherePart(drawable, radius, 5, 5, -5, 50, elevationLowerLimit, elevationUpperLimit, backgroundColor,GL_LINE,0);
				drawHorizontalCircleLine(drawable,radius,5,0,elevationLowerLimit,elevationUpperLimit,searchColor);
				drawHorizontalCircleLine(drawable,radius,5,30,elevationLowerLimit,elevationUpperLimit,searchColor);
				for (int index = elevationLowerLimit+15-elevationLowerLimit%15; index <= elevationUpperLimit; index = index + 15)
				{
					drawCircleLinePart(drawable, radius, 5, index,-5, 50,searchColor);		
				}
			}
			else if ( ((azimuth > 45 ) && (azimuth <= 90)) )
			{
				drawSpherePart(drawable, radius, 5, 5, 40, 95, elevationLowerLimit, elevationUpperLimit, backgroundColor,GL_LINE,0);
				drawHorizontalCircleLine(drawable,radius,5,60,elevationLowerLimit,elevationUpperLimit,searchColor);
				drawHorizontalCircleLine(drawable,radius,5,90,elevationLowerLimit,elevationUpperLimit,searchColor);
				for (int index = elevationLowerLimit+15-elevationLowerLimit%15; index <= elevationUpperLimit; index = index + 15)
				{
					drawCircleLinePart(drawable, radius, 5, index,40, 95,searchColor);		
				}
			}
			else if ( ((azimuth > 90 ) && (azimuth <= 135)) )
			{
				drawSpherePart(drawable, radius, 5, 5, 85, 140, elevationLowerLimit, elevationUpperLimit, backgroundColor,GL_LINE,0);
				drawHorizontalCircleLine(drawable,radius,5,90,elevationLowerLimit,elevationUpperLimit,searchColor);
				drawHorizontalCircleLine(drawable,radius,5,120,elevationLowerLimit,elevationUpperLimit,searchColor);
				for (int index = elevationLowerLimit+15-elevationLowerLimit%15; index <= elevationUpperLimit; index = index + 15)
				{
					drawCircleLinePart(drawable, radius, 5, index,85, 140,searchColor);		
				}
			}
			else if ( ((azimuth > 135 ) && (azimuth <= 180)) )
			{
				drawSpherePart(drawable, radius, 5, 5, 130, 185, elevationLowerLimit, elevationUpperLimit, backgroundColor,GL_LINE,0);
				drawHorizontalCircleLine(drawable,radius,5,150,elevationLowerLimit,elevationUpperLimit,searchColor);
				drawHorizontalCircleLine(drawable,radius,5,180,elevationLowerLimit,elevationUpperLimit,searchColor);
				for (int index = elevationLowerLimit+15-elevationLowerLimit%15; index <= elevationUpperLimit; index = index + 15)
				{
					drawCircleLinePart(drawable, radius, 5, index,130, 185,searchColor);		
				}
			}
			else if ( ((azimuth > 180 ) && (azimuth <= 225)) )
			{
				drawSpherePart(drawable, radius, 5, 5, 175, 230, elevationLowerLimit, elevationUpperLimit, backgroundColor,GL_LINE,0);
				drawHorizontalCircleLine(drawable,radius,5,180,elevationLowerLimit,elevationUpperLimit,searchColor);
				drawHorizontalCircleLine(drawable,radius,5,210,elevationLowerLimit,elevationUpperLimit,searchColor);
				for (int index = elevationLowerLimit+15-elevationLowerLimit%15; index <= elevationUpperLimit; index = index + 15)
				{
					drawCircleLinePart(drawable, radius, 5, index,175, 230,searchColor);		
				}
			}
			else if ( ((azimuth > 225 ) && (azimuth <= 270)) )
			{
				drawSpherePart(drawable, radius, 5, 5, 220, 275, elevationLowerLimit, elevationUpperLimit, backgroundColor,GL_LINE,0);
				drawHorizontalCircleLine(drawable,radius,5,240,elevationLowerLimit,elevationUpperLimit,searchColor);
				drawHorizontalCircleLine(drawable,radius,5,270,elevationLowerLimit,elevationUpperLimit,searchColor);
				for (int index = elevationLowerLimit+15-elevationLowerLimit%15; index <= elevationUpperLimit; index = index + 15)
				{
					drawCircleLinePart(drawable, radius, 5, index,220, 275,searchColor);		
				}
			}	    	
			else
			{
				drawSpherePart(drawable, radius, 5, 5, 265, 320, elevationLowerLimit, elevationUpperLimit, backgroundColor,GL_LINE,0);
				drawHorizontalCircleLine(drawable,radius,5,300,elevationLowerLimit,elevationUpperLimit,searchColor);
				drawHorizontalCircleLine(drawable,radius,5,270,elevationLowerLimit,elevationUpperLimit,searchColor);
				for (int index = elevationLowerLimit+15-elevationLowerLimit%15; index <= elevationUpperLimit; index = index + 15)
				{
					drawCircleLinePart(drawable, radius, 5, index,265, 320,searchColor);		
				}
			}
		}
		else
		{
			// in feedback mode, print grid to include both training position and crossair position
			double directionMod = (trainSection.markedAzimuth*10)%1;
    		double newAzimuth = trainSection.markedAzimuth-directionMod/10;
    		directionMod = trainSection.markedElevation%1;
    		double newElevation = trainSection.markedElevation - directionMod;
    		double width = trainSection.fieldWidth;
    		
    		
        	int startAzimuth = (int)Math.min(azimuth,newAzimuth);
        	if (startAzimuth >= 180)
        	{
        		startAzimuth = startAzimuth-360;
        	}
        	int endAzimuth = (int)Math.max(azimuth, newAzimuth);
        	if (endAzimuth >= 180)
        	{
        		endAzimuth = endAzimuth-360;
        	}
        	
        	
        	int startAzimuthFinal = Math.min(startAzimuth,endAzimuth) - 5;
        	int endAzimuthFinal = Math.max(startAzimuth,endAzimuth) + 5;
        	
			drawSpherePart(drawable, radius, 5, 5, startAzimuthFinal, endAzimuthFinal, elevationLowerLimit, elevationUpperLimit, backgroundColor,GL_LINE,0);
			drawHorizontalCircleLine(drawable,radius,5,endAzimuthFinal,elevationLowerLimit,elevationUpperLimit,searchColor);
			drawHorizontalCircleLine(drawable,radius,5,startAzimuthFinal,elevationLowerLimit,elevationUpperLimit,searchColor);
			for (int index = elevationLowerLimit+15-elevationLowerLimit%15; index <= elevationUpperLimit; index = index + 15)
			{
				drawCircleLinePart(drawable, radius, 5, index,startAzimuthFinal, endAzimuthFinal,searchColor);		
			}
			
			
		}

	}

	@Override
	public void dispose(GLAutoDrawable arg0) {
		// TODO Auto-generated method stub
		
	}
}   



