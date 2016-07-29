package ita.listeningTestGUI;

import java.util.Vector;

import javax.media.opengl.GL;
import javax.media.opengl.GL2;
import javax.media.opengl.GLAutoDrawable;


import static javax.media.opengl.GL.*; // GL constants
import static javax.media.opengl.GL2.*; // GL2 constants


public class BlockGLMode extends MainGLWindowBasis{

	private Vector<MarkedStruct> blockPositions = new Vector<MarkedStruct>(3*12);
	private ColorClass backgroundColorMoreAlpha = new ColorClass(0.5f,0.5f,0.5f,0.05f);
	private ColorClass invisibleColor = new ColorClass(0.5f,0.5f,0.5f,0f);
	
	public BlockGLMode(abstractInput event, OpenGLWindowAdapter wA) 
	{
		super(event,wA);

		
		backgroundColor.colorArray[0] = 0.5f;
		backgroundColor.colorArray[1] = 0.5f;
		backgroundColor.colorArray[2] = 0.5f;
		backgroundColor.colorArray[3] = 0.5f;
		
		
		searchColor.colorArray[0] = 0;
		searchColor.colorArray[1] = 0;
		searchColor.colorArray[2] = 0;	
		searchColor.colorArray[3] = 0.8f;
		
	}
	
	//numExtraRows is the number of block-rows with elevation < 90°
	protected void setBlockPositions(int numExtraRows, int divideBlockInto, int width, int addMarkWidth)
	{
		
		/**
		 * @param numExtraRows		-	number of block-rows with elevation < 90°
		 * @param divideBlockInto	-	divides each Block into "x" pieces
		 * @param width				-	the actual width of the Blocks
		 * @param addMarkWidth		-	the additional width for selecting
		 * 								distance between Blocks is double the value
		 */
		
		
		//if( (numExtraRows%2) == 1 )
		//{
		//	numExtraRows += 1;
		//}
		
		//Too many extra rows?
		if(numExtraRows > 90/(width+addMarkWidth) - 1)
		{
			numExtraRows = (int)(90/(width+addMarkWidth)) - 1;
			System.out.println("Too many Rows for this width. Correcting to maximum row number");
		}		
		
		int numAzimuth = (int)( 360/(width+addMarkWidth) );
		int numElevation = 1 + 2*numExtraRows;
		int BlockDistance = width + addMarkWidth;
		
		//blockPositions.setSize(numAzimuth*numElevation);
		
		for	(int indexElevation = 0; indexElevation < numElevation; indexElevation++)
		{
			for (int index = indexElevation*numAzimuth; index < (indexElevation+1)*numAzimuth; ++index)
			{				
				blockPositions.add(new MarkedStruct());
				//this sets the width of the block that is painted
				blockPositions.get(index).setFieldWidth(width);
				// this sets an additional border around the block where it is still selected
				blockPositions.get(index).setAdditionalMarkWidth(addMarkWidth);
				blockPositions.get(index).mark( (index*BlockDistance)%360, 90 + BlockDistance*(numExtraRows - indexElevation) );
			}
		}
		
	}
	
	public void display(GLAutoDrawable drawable) {

		// get the current state from the input device
		double azimuth = inputObject.getAzimuthDirection();
		double magnitude = inputObject.getAzimuthMagnitude();
		double elevation = inputObject.getElevationDirection();
	
		
		if (elevation < elevationLowerLimit)
		{
			elevation = elevationLowerLimit;
		}
		
		if (elevation > elevationUpperLimit)
		{
			elevation = elevationUpperLimit;
		}
		
		
		GL2 gl = drawable.getGL().getGL2();
		// Clear the color and the depth buffers
		gl.glClear(GL.GL_COLOR_BUFFER_BIT | GL.GL_DEPTH_BUFFER_BIT);



		// rotate the view to look from behind and slightly above horizontal axis

		gl.glLoadIdentity();                // reset the current model-view matrix
		gl.glTranslatef(0f, 0.0f, -7.0f);
		gl.glRotatef(60, -1.0f, 0.0f, 0.0f); // rotate about the x, y and z-axes
		gl.glRotatef(90, 0.0f, 0.0f, 1.0f); // rotate about the x, y and z-axes

		// draw the background images
		drawBackground(drawable,azimuth,magnitude);
		double azimuthMod = (azimuth*10)%1;
		double realAzimuth = azimuth-azimuthMod/10;
		azimuthMod = elevation%1;
		if (perspective == 180)
    	{
    		realAzimuth = (realAzimuth + 180) % 360;
    	}
	
		// if the input is active, display
		if (magnitude > 0.5)
		{
			for (int index = 0; index < blockPositions.size(); ++index)
			{
				drawBlock(drawable, blockPositions.get(index),azimuth,elevation,1);
			}
		}
		else
		{
			//instead of background painting, the blocks are drawn as inactive
			for (int index = 0; index < blockPositions.size(); ++index)
			{
				drawBlock(drawable, blockPositions.get(index),azimuth,elevation,0);
			}
		}
		
		drawOverlay(drawable);

		gl.glFlush();
	}

	private void drawBlock(GLAutoDrawable drawable, MarkedStruct currentBlock, double azimuth, double elevation, int active) 
	{
		double directionMod = (currentBlock.markedAzimuth*10)%1;
		double newAzimuth = currentBlock.markedAzimuth-directionMod/10;
		directionMod = currentBlock.markedElevation%1;
		double newElevation = currentBlock.markedElevation - directionMod;
		double width = currentBlock.fieldWidth;
		
		int training = 0;
		int userSelected = 0;
		int controllerSelected = 0;
		
		// is the current block marked for training
		if (trainSection.isMarked == 1)
		{
			if (currentBlock.isWithinMarkedArea(trainSection.markedAzimuth, trainSection.markedElevation) == 1)
			{
				training = 1;
			}
		}
		
		// is the current block marked by the user
		if (isMarked.isMarked == 1)
		{
			if (currentBlock.isWithinMarkedArea(isMarked.markedAzimuth, isMarked.markedElevation) == 1)
			{
				isMarked = new MarkedStruct(currentBlock);
				userSelected = 1;
			}
		}
		
		// is the current block selected by the controller position
		if ( (currentBlock.isWithinMarkedArea(azimuth,elevation) == 1) && (active == 1) )
		{
			controllerSelected = 1;
		}
		
		ColorClass color;
		color = backgroundColor;
		if ( controllerSelected == 1 )
		{
			color = searchColor;
		}
		else
		{
			if (dynamicAlphaMode == 1)
			{
				// blend out the read blocks if the controller is not there
				if ( (145 <= newAzimuth) && (newAzimuth < 225))
				{
					if (training == 0)
					{					
						float alpha = (float) ((Math.cos(((newAzimuth-azimuth)/180*Math.PI))+1)/2);
						color = backgroundColorMoreAlpha;
						color.colorArray[3] = alpha;
					}
					
					if (active == 0)	//dirty hack to display idle state
					{
						color = invisibleColor;
					}
				}
			}
		}
		
		
		if (training == 1)
		{
			color = trainColor;
		}
		
		//do not mark block if inHeadlocalization
		if (userSelected == 1 && inHeadLocalization == 0)
		{
			color = markedColor;
		}
		

		if ( ( controllerSelected == 1 ) && (training == 1))
		{
			color = trainAndSelectedColor;
		}
			
		if ( ( controllerSelected == 1 ) && (userSelected == 1) && (inHeadLocalization == 0) )
		{
			color = markedAndSelectedColor;
		}
		drawSpherePart(drawable, radius, 1, 1, newAzimuth-Math.floor(width/2), newAzimuth+Math.ceil(width/2), newElevation-Math.floor(width/2), newElevation + Math.ceil(width/2),color,GL_FILL,1);

	}

    public void setNewBlocks(int numberOfBlocks, float[] azimuthValues, float[] elevationValues, float[] blockWidth, float[] additionalWidth)
    {
    	
    	//check array length
    	if(numberOfBlocks != azimuthValues.length || numberOfBlocks != elevationValues.length || numberOfBlocks != blockWidth.length || numberOfBlocks != additionalWidth.length)
    	{
    		System.out.println("Error in 'setBlocks': Array lengths do not match the number of blocks");
    		return;
    	}
    	
    	// it probably is a good idea to stop the animator while reseting the blocks
    	animator.stop();
    	blockPositions.clear();
    	
    	float elevationMin = 200;
    	float elevationMax = 0;
    	
    	// repopulate the blockPositions
    	for (int blockIdx = 0; blockIdx < numberOfBlocks; blockIdx++)
    	{
    		blockPositions.addElement(new MarkedStruct());
    		
    		blockPositions.get(blockIdx).setAdditionalMarkWidth((int)additionalWidth[blockIdx]);
    		blockPositions.get(blockIdx).setFieldWidth((int)blockWidth[blockIdx]);
    		blockPositions.get(blockIdx).mark((double)azimuthValues[blockIdx], (double)elevationValues[blockIdx]);
    		
    		// get the min and the max values from the elevation values
    		if (elevationValues[blockIdx] < elevationMin)
    		{
    			elevationMin = elevationValues[blockIdx];
    		}
    		if (elevationValues[blockIdx] > elevationMax)
    		{
    			elevationMax = elevationValues[blockIdx];
    		}
    	}
     	//set the elevation limits to the controller
    	inputObject.setElevationLimits(elevationMin, elevationMax);
    	
    	animator.start();
    }

	@Override
	public void dispose(GLAutoDrawable arg0) {
		// TODO Auto-generated method stub
		
	}
}
